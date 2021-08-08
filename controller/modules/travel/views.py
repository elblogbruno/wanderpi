from controller.models.models import Travel
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.travel import travel_blu
from controller.modules.files.views import create_folder_structure_for_travel, get_travel_folder_path
from flask import redirect, request, jsonify, send_from_directory,send_file
from datetime import *
import uuid
import shutil
import os
from time import sleep

from flask_socketio import emit
from controller import socketio
from controller.utils.video_editor import VideoEditor

finished_editing = False
download_status = 'Started creating video of your trip...'

@travel_blu.route('/delete_travel/<string:travel_id>')
def delete_travel(travel_id):
    travel = Travel.get_by_id(travel_id)
    travel.delete_all_wanderpis()
    travel.delete(travel_id)
    return redirect("/", code=302)

def toDate(dateString):
    print(dateString)
    return datetime.strptime(dateString, "%Y-%m-%d") #example datetime input 2021-07-01

@travel_blu.route('/save_travel/', methods=['GET', 'POST'])
def save_travel(): #todo get available video sources from database
    print("Saving travel")
    
    name = request.args.get('name')
    destination = request.args.get('destination')
    start_date = request.args.get('start_date', type=toDate)
    end_date = request.args.get('end_date', type=toDate)
    travel_id = str(uuid.uuid4())

    create_folder_structure_for_travel(travel_id)

    travel_folder_path = get_travel_folder_path(travel_id=travel_id, file_type='root') 

    travel = Travel(id=travel_id, name=name, lat="0", long="0", travel_folder_path=travel_folder_path, destination=destination, start_date=start_date, end_date=end_date)
    travel.save()

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

    videos = travel.get_all_wanderpis()
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
        
    final_video_path = VideoEditor.JoinVideos(video_paths, final_video_id, travel_id, video_path)
    
    finished_editing = True
    download_status = 'Travel video finished, it will download automatically or you can access it here: {0}'.format(final_video_path)
    emit('travel_download_update', download_status)
    sleep(0.1)
    emit('travel_download_update', "200")
    
    return send_file(final_video_path, mimetype='video/mp4', as_attachment=True, attachment_filename=travel.name+'.mp4')
