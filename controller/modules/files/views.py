from genericpath import isfile
from config import load_custom_video_folder

from flask import session, jsonify, flash, request, redirect, render_template,send_from_directory,url_for
from werkzeug.utils import secure_filename

from controller.modules.files.video_utils import VideoUtils
from controller.models.models import Point, Travel, Wanderpi, Stop
from controller.modules.home import geocode_utils
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.files import files_blu
from controller.modules.files.utils import *
from controller.utils.utils import create_folder
from controller.utils.image_editor import ImageEditor
from controller.utils.video_editor import VideoEditor

from flask_socketio import emit
from controller import socketio
from os import listdir
from os.path import isfile, join
from time import sleep
import uuid
import shutil



latest_message = 'Hi'
latest_message_counter = 'hi'
uploading_files = False
STATIC_FOLDER = '/wanderpi/wanderpis/'

number_of_files = 0
counter = 0


def create_folder_structure_for_travel(travel_id):
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()

    create_folder(VIDEOS_FOLDER + str(travel_id))
    # create_folder(VIDEOS_FOLDER + str(travel_id) + '/images')
    # create_folder(VIDEOS_FOLDER + str(travel_id) + '/videos')
    # create_folder(VIDEOS_FOLDER + str(travel_id) + '/thumbnails')

def rename_stop_folder(travel_id, old_name, new_name):
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()

    old_upload_path = UPLOAD_FOLDER + str(old_name)
    old_path = VIDEOS_FOLDER + str(travel_id) + '/' + str(old_name)
    
    new_upload_path = UPLOAD_FOLDER + str(new_name)
    new_path = VIDEOS_FOLDER + str(travel_id) + '/' + str(new_name)
     
    os.rename(old_upload_path, new_upload_path)
    os.rename(old_path, new_path)
    
    Stop.rename_all_wanderpi_paths(new_name, old_name)


def create_folder_structure_for_stop(travel_id, name=None, stop_id=None):
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()
    print("Creating folder structure for stop {0}".format(travel_id))
    if stop_id:
        stop = Stop.get_by_id(stop_id)
        create_folder(UPLOAD_FOLDER + str(stop.name))
        create_folder(VIDEOS_FOLDER + str(travel_id) + '/' + str(stop.name) + '/images/')
        create_folder(VIDEOS_FOLDER + str(travel_id) + '/' + str(stop.name) + '/videos/')
        create_folder(VIDEOS_FOLDER + str(travel_id) + '/' + str(stop.name) + '/thumbnails/')       
    else:
        path = UPLOAD_FOLDER+str(name)
        print(path)
        create_folder(path)
        create_folder(VIDEOS_FOLDER + str(travel_id) + '/' + str(name) + '/images/')
        create_folder(VIDEOS_FOLDER + str(travel_id) + '/' + str(name) + '/videos/')
        create_folder(VIDEOS_FOLDER + str(travel_id) + '/' + str(name) + '/thumbnails/')
        
#get_travel_folder_path_static
#get_travel_folder_path
def get_file_path(travel_id, stop_id, filename_or_file_id= None, file_type = 'images', static = False):
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()
    
    root = STATIC_FOLDER if static else VIDEOS_FOLDER
    stop = Stop.get_by_id(stop_id)

    init_path = root + str(travel_id) + '/' + stop.name
    if filename_or_file_id and stop_id:
        if file_type == 'images':
            return init_path + '/images/' + str(filename_or_file_id)
        elif file_type == 'videos':
            if '.mp4' in filename_or_file_id:
                return init_path + '/videos/'+  str(filename_or_file_id)
            else:
                return init_path + '/videos/'+  str(filename_or_file_id) + '.mp4'
        elif file_type == 'thumbnails':
            return init_path + '/thumbnails/thumbnail-%s.jpg' % str(filename_or_file_id)

    else:
        if file_type == 'images':
            return init_path + '/images'
        elif file_type == 'videos':
            return init_path + '/videos'
        elif file_type == 'thumbnails':
            return init_path + '/thumbnails'

def get_stop_upload_path(stop_name, stop_id=None):
    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()
    if stop_id:
        stop = Stop.get_by_id(stop_id)
        return UPLOAD_FOLDER + str(stop.name)
    else:
        path = UPLOAD_FOLDER+str(stop_name)
        return path   

def upload_file_to_database(file_path, static_path , filename, travel_id, stop_id):
    print("Adding file {0} to database".format(file_path))

    if (get_file_extension(file_path) in IMAGE_EXTENSIONS):
        # read the image data using PIL
        lat, long, created_date,is_360 = get_file_tags(file_path, filename)
        file_id = str(uuid.uuid4()) 
        #file_thumbnail_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename)
        abs_file_path = get_file_path(travel_id=travel_id, stop_id=stop_id, filename_or_file_id=filename)
        abs_file_thumbnail_path = get_file_path(travel_id=travel_id, stop_id=stop_id, filename_or_file_id=file_id, file_type='thumbnails')
        
        file_thumbnail_path = get_file_path(travel_id=travel_id, filename_or_file_id=file_id, stop_id=stop_id, file_type='thumbnails', static=True)

        ImageEditor.create_thumbnail(file_path, abs_file_thumbnail_path, (500,500))

        save_file_to_database(True, travel_id, stop_id, filename, lat, long, file_id, file_thumbnail_path, abs_file_path, created_date=created_date, is_360=is_360)
        
    elif (get_file_extension(file_path) in VIDEO_EXTENSIONS):
        lat, long, created_date, duration, is_360 = get_file_tags(file_path,filename, file_type='video')
        file_id = str(uuid.uuid4()) 
        
        abs_file_path = get_file_path(travel_id=travel_id, stop_id=stop_id, file_type='thumbnails')

        VideoUtils.save_video_thumbnail(file_path, abs_file_path, file_id)

        static_thumbnail_path = get_file_path(travel_id=travel_id, filename_or_file_id=file_id, stop_id=stop_id, file_type='thumbnails', static=True)

        save_file_to_database(False,travel_id, stop_id, filename, lat, long, file_id, static_thumbnail_path, static_path, filename, True, created_date=created_date, video_duration=duration, is_360=is_360)
    else:
        print("File not supported")

def save_file_to_database(is_image, travel_id, stop_id, name, lat_coord, long_coord, file_id, file_thumbnail_path= None, file_path = None, filename=None, edit_video=False, created_date=None, video_duration=None,is_360=False):
    time_duration = 0

    if not is_image:
        if file_path is None:
            video_file_path  = get_file_path(travel_id=travel_id,stop_id=stop_id, filename_or_file_id=filename, file_type='videos')
            file_path = get_file_path(travel_id=travel_id, filename_or_file_id=filename, stop_id=stop_id, file_type='videos', static=True)
        if filename:
            video_file_path  = get_file_path(travel_id=travel_id,stop_id=stop_id, filename_or_file_id=filename, file_type='videos')
            file_path = get_file_path(travel_id=travel_id, filename_or_file_id=filename, stop_id=stop_id, file_type='videos', static=True)
            #if edit_video:
                #VideoEditor.AddTitleToVideo(video_file_path, filename, travel_id, name)

        if file_thumbnail_path is None:
            file_thumbnail_path = get_file_path(travel_id=travel_id, filename_or_file_id=filename, stop_id=stop_id, file_type='thumbnails', static=True)
        
        if video_duration:
            if video_duration > 0:
                time_duration = video_duration
            else:
                time_duration = VideoUtils.get_video_info(video_file_path)
        else:
            time_duration = VideoUtils.get_video_info(video_file_path)
    
    stop = Stop.get_by_id(stop_id)
    if lat_coord == 0 and long_coord == 0:
        lat_coord = stop.lat
        long_coord = stop.long
        address = stop.name
    else:
        #address = GeoCodeUtils.reverse_latlong(lat_coord, long_coord)
        #In the future will make a bot thtat does this on background.
        address = stop.name

    #remove everything till it reaches the word wanderpi
    cdn_path = '/wanderpi/'+file_path.split('/wanderpi/')[-1]

    video = Wanderpi(id=file_id, name=name, lat=lat_coord, long=long_coord, file_thumbnail_path=file_thumbnail_path, travel_id=travel_id, stop_id=stop_id, address=address, time_duration=time_duration, file_path=file_path, cdn_path=cdn_path, is_image=is_image, has_been_edited=edit_video, created_date=created_date, is_360=is_360)
    video.save()

    return "ok"

def delete_file_from_database(file_id):
    try:
        video = Wanderpi.get_by_id(file_id)
        stop_id = video.stop_id

        video.delete()

        return stop_id
    except:
        return "error"


@files_blu.route('/bulk_edit_files', methods=['POST'])
def bulk_edit_files():
    if request.method == 'POST':
        json = request.json

        files_to_edit = json['files_to_edit']
        print("Editing these files: {0}".format(files_to_edit))

        address = None
        if 'lat' in json and 'long' in json:
            address = GeoCodeUtils.reverse_latlong(json['lat'], json['long'])
        
        for file in files_to_edit:
            file = Wanderpi.get_by_id(file)
            lat = json['lat'] if 'lat' in json.keys() else file.lat #if we have a new lat for the file on the, update it
            file.lat = lat
            long = json['long'] if 'long' in json.keys() else file.long #if we have a new long for the file on the, update it
            file.long = long
            name = json['name'] if 'name' in json.keys() else file.name #if we have a new name for the file on the, update it
            file.name = name
            stop_id = json['stop_id'] if 'stop_id' in json.keys() else file.stop_id #if we have a new name for the file on the, update it
            file.stop_id = stop_id
            if address: 
                file.address = address
            file.save()

        print("Files edited succesfully!")
        return jsonify({"error": 0})
    else:
        if request.referrer:
            return redirect(request.referrer)
        return redirect("/")

@files_blu.route('/bulk_delete_files', methods=['POST'])
def bulk_delete_files():
    if request.method == 'POST':
        files_to_delete = request.json
        try:
            for file in files_to_delete:
                stop_id = delete_file_from_database(file)
        except: 
            return jsonify(error = 0, message = "Error deleting file")

        return redirect(url_for('home.stop', stop_id=stop_id), code=302)
    else:
        if request.referrer:
            return redirect(request.referrer)
        return redirect("/")

@files_blu.route('/delete_file/<string:file_id>')
def delete_file(file_id):
    stop_id = delete_file_from_database(file_id)
    
    if stop_id:
        return redirect(url_for('home.stop', stop_id=stop_id), code=302)
    else:
        return redirect('/')  

@files_blu.route('/save_file/<string:file_id>/', methods=['GET', 'POST'])
def save_file(file_id): #todo get available video sources from database
    print("Saving file {0}".format(file_id))
    
    if request.method == 'POST':
        json = request.json

        boolean = json['is_image']
        is_image = True if boolean == 'true' else False
        stop_id = json['stop_id']
        travel_id = Stop.get_by_id(stop_id).travel_id
        

        name = json['name'] if 'name' in json.keys() else file_id
        if len(name) == 0:
            name = file_id

        lat_coord = json['lat']
        long_coord = json['long']
        file_thumbnail_path = json['thumbnail_url'] if 'thumbnail_url' in json.keys() else None
        file_path = json['file_path'] if 'file_path' in json.keys() else None
        points = json['points']

        for point in points:
            print(point)
            lat = point['lat']
            long = point['long']
            p = Point(id=str(uuid.uuid4()),lat=lat, long=long, file_owner_id=file_id)
            p.save()

        save_file_to_database(is_image,travel_id, stop_id, name, lat_coord, long_coord, file_id, file_thumbnail_path, file_path, file_id)

        return jsonify(status_code = 200, message = "OK")
    else:
        if request.referrer:
            return redirect(request.referrer)
        return redirect("/")

# @files_blu.route('/get_file_info/<string:file_id>')

@files_blu.route('/get_video_info/<string:video_id>', methods=['GET', 'POST'])
def get_video_info(video_id):
    if video_id:
        video = Wanderpi.get_by_id(video_id)
        video_info = VideoUtils.get_video_info(video.video_location_path)
        
        return jsonify(video_id=video_id, video_info=video_info, status_code = 200, message = "OK")
    else:
        print("No travel id found")
        return jsonify(status_code = 400, message = "No travel id found")

@files_blu.errorhandler(413)
def request_entity_too_large(error):
     return  jsonify(error= 1, message='File Too Large')

@files_blu.route('/upload/<string:stop_id>', methods=['POST','GET'])
def upload_file(stop_id):

    if request.method == 'POST':        
        travel_id = Stop.get_by_id(stop_id).travel_id
        create_folder_structure_for_stop(travel_id=travel_id, stop_id=stop_id)

        for key, file in request.files.items():
            if key.startswith('file'):
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    file_type = 'images' if get_file_extension(filename) in IMAGE_EXTENSIONS else 'videos'
                    path = get_file_path(travel_id=travel_id,stop_id=stop_id, filename_or_file_id=filename, file_type=file_type)
                    static_path = get_file_path(travel_id=travel_id, filename_or_file_id=filename, stop_id=stop_id, file_type=file_type, static=True)
                    
                    if not os.path.isfile(path):     
                        if not os.path.isdir(path):
                            create_folder_structure_for_travel(travel_id)
                        file.save(path)
                        upload_file_to_database(path, static_path, filename, travel_id, stop_id)
                    else:
                        return 'File already exists', 400
                    #counter += 1
                else:
                    return 'MP4 Videos only!', 400


        travel = Travel.get_by_id(travel_id)
        if travel:
            wanderpis = travel.get_all_wanderpis()
        
        return render_template("travel_view.html", wanderpis=wanderpis, travel=travel)

    else:
        if request.referrer:
            return redirect(request.referrer)
        return redirect("/travel/"+travel_id)

@files_blu.route('/completed')
def completed():
    print(request.referrer)
    return redirect('/', code=302)

@socketio.on("update")
def update(data):
    global counter
    global number_of_files
    print('Message from browser', data, counter, number_of_files)
    
    if counter < number_of_files:
        emit('update', 'File {0} successfully uploaded'.format(counter+1))
    


@socketio.on("get_upload_status")
def get_upload_status(data):
    #browser will ask for this to see if we are uploading files.
    global uploading_files
    emit('get_upload_status', str(uploading_files))
    if uploading_files:
        emit('process_travel_upload_folder_update', 'Reconecting to socket!')

def recreate_stops_thumbnail(stop_id,emit_key, file_type='images'):
    global latest_message
    global latest_message_counter
    
    stop =  Stop.get_by_id(stop_id)
    
    stop_name = stop.name
    travel_id = stop.travel_id

    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()
        
    file_path = get_file_path(travel_id=travel_id, stop_id=stop_id, file_type=file_type)
    
    # final_folder_path = VIDEOS_FOLDER + stop_name + "/"
    create_folder_structure_for_stop(travel_id=travel_id, stop_id=stop_id)

    try:
        upload_files = [f for f in listdir(file_path) if isfile(join(file_path, f))]
        total_files = len(upload_files)
        counter = 0
        if len(upload_files) > 0:
            for file in upload_files:                
                emit(emit_key, 'Recreating thumbnail for file {0}'.format(file))
                print('Recreating thumbnail for file {0}'.format(file))
                latest_message = 'Recreating thumbnail for file {0}'.format(file)
                
                file_path = get_file_path(travel_id=travel_id, stop_id=stop_id, filename_or_file_id=file, file_type=file_type)
                static_path = get_file_path(travel_id=travel_id, filename_or_file_id=file, stop_id=stop_id, file_type=file_type, static=True)
                abs_file_thumbnail_path = get_file_path(travel_id=travel_id, stop_id=stop_id, filename_or_file_id=file, file_type='thumbnails')
                
                if file_type == 'images':
                    ImageEditor.create_thumbnail(file_path, abs_file_thumbnail_path, (500,500))
                else:
                    VideoUtils.save_video_thumbnail(file_path, abs_file_thumbnail_path, file)

                emit(emit_key, 'File {0} thumbnail recreated succesfully'.format(file.encode('utf-8')))
                latest_message =  'File {0} thumbnail recreated succesfully'.format(file.encode('utf-8'))

                if counter < total_files:
                    counter += 1
                    emit('process_upload_folder_update_counter', 'File {0} out of {1}'.format(counter, total_files))
                    print('File {0} out of {1}'.format(counter, total_files))
                    latest_message_counter = 'File {0} out of {1}'.format(counter, total_files)
                else:
                    print("Done")

            sleep(0.1)
            emit(emit_key, "200")
            latest_message = "200"
            uploading_files = False
        else:
            emit(emit_key, "No files on the uploads folder")
            print('No files on the uploads folder')
            latest_message = 'No files on the uploads folder'
            sleep(2)
            emit(emit_key, "")
            latest_message = ""
            emit(emit_key, "200")
            latest_message = "200"
            uploading_files = False

        return "200"
    except OSError as e:
        emit(emit_key, str(e))
        latest_message = str(e)
        sleep(2)
        emit(emit_key, "200")
        latest_message = "200"
        return "200"

@socketio.on("process_recreate_thumbnails")
def process_recreate_thumbnails(stop_id):
    #for every file in the uploads folder, upload it to the database
    global latest_message
    global latest_message_counter
    if stop_id == 'ok':
        print("user conected again")
        emit('process_upload_folder_update', latest_message)
        emit('process_upload_folder_update_counter', latest_message_counter)
        emit('process_upload_folder_update_counter', latest_message_counter)
    else:
        global uploading_files
        uploading_files = True
        recreate_stops_thumbnail(stop_id=stop_id, emit_key="process_upload_folder_update")


def process_stop_files(stop_id,emit_key):
    global latest_message
    global latest_message_counter
    
    stop =  Stop.get_by_id(stop_id)
    
    stop_name = stop.name
    travel_id = stop.travel_id

    CUSTOM_STATIC_FOLDER, VIDEOS_FOLDER, UPLOAD_FOLDER = load_custom_video_folder()
        
    final_folder_path = UPLOAD_FOLDER + stop_name + "/"
    create_folder_structure_for_stop(travel_id=travel_id, stop_id=stop_id)

    try:
        upload_files = [f for f in listdir(final_folder_path) if isfile(join(final_folder_path, f))]
        total_files = len(upload_files)
        counter = 0
        if len(upload_files) > 0:
            for file in upload_files:                
                emit(emit_key, 'Uploading file {0}'.format(file))
                print('Uploading file {0}'.format(file))
                latest_message = 'Uploading file {0}'.format(file)
                path_to_move_file = final_folder_path+file
                if (get_file_extension(file) in IMAGE_EXTENSIONS):
                    #move file to images folder
                    file_type = 'images'
                elif (get_file_extension(file) in VIDEO_EXTENSIONS):
                    #move file to videos folder
                    file_type = 'videos'
                else:
                    print("File not allowed")

                path = get_file_path(travel_id=travel_id, stop_id=stop_id, filename_or_file_id=file, file_type=file_type)
                static_path = get_file_path(travel_id=travel_id, filename_or_file_id=file, stop_id=stop_id, file_type=file_type, static=True)
                
                if not os.path.isfile(path):
                    shutil.move(path_to_move_file, path)
                    upload_file_to_database(path, static_path, file, travel_id, stop_id)
                    emit(emit_key, 'File {0} successfully uploaded'.format(file.encode('utf-8')))
                    print('File {0} successfully uploaded'.format(file.encode('utf-8')))
                    latest_message = 'File {0} successfully uploaded'.format(file.encode('utf-8'))
                else:
                    print("File already exists")
                    os.remove(join(final_folder_path, file))
                    emit(emit_key, 'File {0} already exists'.format(file.encode('utf-8')))
                    print('File {0} already exists'.format(file.encode('utf-8')))
                    latest_message = 'File {0} already exists'.format(file.encode('utf-8'))
                
                if counter < total_files:
                    counter += 1
                    emit('process_upload_folder_update_counter', 'File {0} out of {1}'.format(counter, total_files))
                    print('File {0} out of {1}'.format(counter, total_files))
                    latest_message_counter = 'File {0} out of {1}'.format(counter, total_files)
                else:
                    print("Done")

            sleep(0.1)
            emit(emit_key, "200")
            latest_message = "200"
            uploading_files = False
        else:
            emit(emit_key, "No files on the uploads folder")
            print('No files on the uploads folder')
            latest_message = 'No files on the uploads folder'
            sleep(2)
            emit(emit_key, "")
            latest_message = ""
            emit(emit_key, "200")
            latest_message = "200"
            uploading_files = False

        return "200"
    except OSError as e:
        emit(emit_key, str(e))
        latest_message = str(e)
        sleep(2)
        emit(emit_key, "200")
        latest_message = "200"
        return "200"


@socketio.on("process_upload_folder_update")
def process_upload(stop_id):
    #for every file in the uploads folder, upload it to the database
    global latest_message
    global latest_message_counter
    if stop_id == 'ok':
        print("user conected again")
        emit('process_upload_folder_update', latest_message)
        emit('process_upload_folder_update_counter', latest_message_counter)
        emit('process_upload_folder_update_counter', latest_message_counter)
    else:
        global uploading_files
        uploading_files = True
        process_stop_files(stop_id=stop_id, emit_key="process_upload_folder_update")

@socketio.on("process_travel_upload_folder_update")
def process_travel_upload(travel_id):
    #for every file in the uploads folder, upload it to the database
    global latest_message
    global latest_message_counter
    if travel_id == 'ok':
        print("user conected again")
        emit('process_travel_upload_folder_update', latest_message)
        emit('process_upload_folder_update_counter', latest_message_counter)
    else:
        global uploading_files
        uploading_files = True
        travel =  Travel.get_by_id(travel_id)
        for stop in travel.get_all_stops(): 
            stop_name = stop.name
            stop_id = stop.id
            emit('process_travel_upload_folder_update', 'Processing stop {0}'.format(stop_name))
            print('Processing stop {0}'.format(stop_name))
            latest_message = 'Processing stop {0}'.format(stop_name)
            status = process_stop_files(stop_id=stop_id, emit_key="process_travel_upload_folder_update")
            if status == "200":
                emit('process_travel_upload_folder_update', 'Finished processing stop {0}'.format(stop_name))
                print('Finished processing stop {0}'.format(stop_name))
                latest_message = 'Finished processing stop {0}'.format(stop_name)
            
            

