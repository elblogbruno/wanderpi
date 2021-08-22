from controller.models.models import Travel, Stop, MoneyInput, Note
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.travel import travel_blu
from controller.modules.files.views import get_stop_upload_path, create_folder_structure_for_travel,create_folder_structure_for_stop, get_travel_folder_path
from flask import redirect, request, jsonify, send_from_directory,send_file,render_template
from datetime import *

import uuid
import shutil
import os
import json
from time import sleep

from flask_socketio import emit
from controller import socketio
from controller.utils.video_editor import VideoEditor

files = []
last_search = ""
finished_editing = False
download_status = 'Started creating video of your trip...'
def datetime_parser(o):
    if isinstance(o, datetime):
        return o.__str__()

@travel_blu.route('/delete_stop/<string:stop_id>')
def delete_stop(stop_id):
    stop = Stop.get_by_id(stop_id)
    travel_id = stop.travel_id
    path = get_stop_upload_path(stop.name)
    stop.delete(path=path)
    return redirect("/travel/"+travel_id, code=302)

@travel_blu.route('/delete_travel/<string:travel_id>')
def delete_travel(travel_id):
    travel = Travel.get_by_id(travel_id)
    travel.delete_all_wanderpis()
    travel.delete_all_stops()
    travel.delete()
    return redirect("/", code=302)

def toDate(dateString):
    print(dateString)
    return datetime.strptime(dateString, "%Y-%m-%d") #example datetime input 2021-07-01

@travel_blu.route('/edit_travel/<string:travel_id>', methods=['POST'])
def edit_travel(travel_id):
    json = request.json
    name = json['name']
    travel = Travel.get_by_id(travel_id)
    travel.name = name
    travel.save()
    return jsonify(status_code=200)

@travel_blu.route('/add_note_to_travel/<string:travel_id>', methods=['POST'])
def add_note_to_travel(travel_id):

    json = request.json

    note_content = json['note_content']
    costs = json['costs']
    note_id = json['note_id'] if 'note_id' in json else str(uuid.uuid4())
    
    total_price = 0

    note = Note.get_by_id(note_id)
    if note:
        all_cost = note.get_all_input()

        for c in all_cost:
            if c.id not in costs:      
                print("Deleting value {0}".format(c.id))
                MoneyInput.delete(c.id)

    for p in costs:
        name = p['name']
        value = float(p['value'])
        total_price += value
        hour = datetime.now().time()
        money_id = p['money_id'] if 'money_id' in p else str(uuid.uuid4())
        print(note_id)
        cost = MoneyInput.get_by_id(money_id)
        if not cost:
            cost = MoneyInput(id=money_id, note_id = note_id, name=name,value=value, hour=hour)
            cost.save()
        else:
            cost.note_id = note_id
            cost.name = name
            cost.value = value
            cost.save()
    
    total_price = round(total_price, 2)
    note = Note.get_by_id(note_id)
    if not note:
        note = Note(id=note_id, travel_id=travel_id, content=note_content, total_price=total_price)
        note.save()
    else:
        note.total_price = total_price
        note.content = note_content
        note.save()
    return jsonify(status_code=200)

@travel_blu.route('/get_note_info/<string:note_id>', methods=['POST'])
def get_note_info(note_id):
    note = Note.get_by_id(note_id)
    if note:
        print("Note id {0} found".format(note_id))
        list_name = note.get_all_input()
        price_input = []
        for ob in list_name:
            a = ob.as_json()
            price_input.append(a)
        # price_input =  json.dumps([ob.as_dict for ob in list_name], default=datetime_parser)
        return jsonify(status_code=200, note_id=note_id, travel_id=note.travel_id, note_content=note.content, total_price=note.total_price, day=note.day, price_input=price_input)
    else:
        return jsonify(note_id="0", travel_id="0", note_content="No content", total_price=0.0, day=None, price_input=[])

@travel_blu.route('/save_travel/', methods=['GET', 'POST'])
def save_travel(): #todo get available video sources from database
    print("Saving travel")
    
    name = request.args.get('name')
    destination = request.args.get('destination')
    start_date = request.args.get('start_date', type=toDate)
    end_date = request.args.get('end_date', type=toDate)
    # notes = request.args.get('notes', default="No notes")
    travel_id = str(uuid.uuid4())

    create_folder_structure_for_travel(travel_id)

    travel_folder_path = get_travel_folder_path(travel_id=travel_id, file_type='root') 

    travel = Travel(id=travel_id, name=name, lat="0", long="0", travel_folder_path=travel_folder_path, destination=destination, start_date=start_date, end_date=end_date)
    travel.save()
    travel.init_calendar()
    return jsonify(status_code = 200, message = "OK")

@travel_blu.route('/add_stop/<string:travel_id>', methods=['GET', 'POST'])
def add_stop(travel_id): #todo get available video sources from database
    print("Adding stop")
    
    name = request.args.get('name')
    stop_id = str(uuid.uuid4())

    create_folder_structure_for_stop(name=name)

    stop = Stop(id=stop_id, travel_id=travel_id, name=name, lat="0", long="0")
    stop.save()

    return jsonify(status_code = 200, message = "OK")

def make_archive(source, destination):
    base = os.path.basename(destination)
    name = base.split('.')[0]
    format = base.split('.')[1]
    archive_from = os.path.dirname(source)
    archive_to = os.path.basename(source.strip(os.sep))
    shutil.make_archive(name, format, archive_from, archive_to)
    shutil.move('%s.%s'%(name,format), destination)

# A function that returns the length of the value:
def myFunc(e):
    return e.created_date

@socketio.on("travel_download_update")
def download_travel(travel_id):
    global finished_editing
    global download_status
    download_status = 'Started creating video of your trip...'
    emit('travel_download_update', download_status)
    finished_editing = False

    travel = Travel.get_by_id(travel_id)
    travel_folder_path = travel.travel_folder_path

    videos = travel.get_all_wanderpis(filter='video')
    videos.sort(key=myFunc)
    video_paths = []
    for video in videos:
        if not video.has_been_edited:
            download_status = 'Editing video {0}'.format(video.name)
            emit('travel_download_update', download_status)
            VideoEditor.AddTitleToVideo("./controller"+ video.file_path, video.id, travel_id, video.name)
            video.has_been_edited = True
            video.save()
        video_paths.append("./controller"+ video.file_path)
    
    final_video_id = str(uuid.uuid4())
    download_status = 'Joining {0} videos from your {1}'.format(len(video_paths), travel.name)
    emit('travel_download_update', download_status)

    video_path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=final_video_id, file_type='videos')
        
    final_video_path = VideoEditor.JoinVideos(video_paths, final_video_id, video_path)
    
    finished_editing = True
    download_status = 'Travel video finished, it will download automatically or you can access it here: {0}'.format(final_video_path)
    emit('travel_download_update', download_status)
    sleep(0.1)
    emit('travel_download_update', "200")
    
    return send_file(final_video_path, mimetype='video/mp4', as_attachment=True, attachment_filename=travel.name+'.mp4')


def search_wanderpis(stop, query):
    print("Searching this: {0}".format(query.lower()))
    final_query = query
    type_filter = False
    global files
    global last_search
    if final_query.lower() != last_search:
        last_search = final_query.lower()
        files = []
    else:
        print("Searching same query")
        return files
        
    per_page=5

    if '%video' in final_query:
        wanderpis = stop.get_all_wanderpis(filter='video')
        final_query = final_query.replace('%video','')
        type_filter = True
    elif '%image' in query:
        wanderpis = stop.get_all_wanderpis(filter='image')
        final_query = final_query.replace('%image','')
        type_filter = True
    else:
        wanderpis = stop.get_all_wanderpis()
    
    if len(final_query) > 0:   
        for file in wanderpis:
            if final_query.lower() in file.name.lower() or final_query.lower() in file.address.lower():
                print(file.name, file.address)
                files.append(file)

    if len(files) == 0 and not type_filter:
        files =  stop.get_all_wanderpis()
        query == 'No results found'
    elif len(files) == 0 and type_filter:
        files = wanderpis

    
    return files
    #return render_template("stops_view.html", wanderpis=wanderpis, stop=stop, travel=travel, pagination=pagination, total_count=total_count, per_page=per_page, search_term=query)  
    #return render_template('travel_view.html', wanderpis=files, travel=travel, search_term=query)

