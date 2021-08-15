from genericpath import isfile
from config import  UPLOAD_FOLDER, VIDEOS_FOLDER

from flask import session, jsonify, flash, request, redirect, render_template,send_from_directory,url_for
from werkzeug.utils import secure_filename

from controller.modules.files.video_utils import VideoUtils
from controller.models.models import Point, Travel, Wanderpi, Stop
from controller.modules.home import geocode_utils
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.files import files_blu
from controller.modules.files.utils import *
from controller.utils.video_editor import VideoEditor

from flask_socketio import emit
from controller import socketio
from os import listdir
from os.path import isfile, join
from time import sleep

import uuid
import shutil
number_of_files = 0
counter = 0


def create_folder_structure_for_travel(travel_id):
    create_folder(VIDEOS_FOLDER + str(travel_id))
    create_folder(VIDEOS_FOLDER + str(travel_id) + '/images')
    create_folder(VIDEOS_FOLDER + str(travel_id) + '/videos')
    create_folder(VIDEOS_FOLDER + str(travel_id) + '/thumbnails')
    
def get_travel_folder_path_static(travel_id, filename_or_file_id= None, file_type = 'images'):
    if filename_or_file_id:
        if file_type == 'images':
            return STATIC_FOLDER + str(travel_id) + '/images/' + str(filename_or_file_id)
        elif file_type == 'videos':
            if '.mp4' in filename_or_file_id:
                return STATIC_FOLDER + str(travel_id) + '/videos/' + str(filename_or_file_id)
            else:
                return STATIC_FOLDER + str(travel_id) + '/videos/' + str(filename_or_file_id) + '.mp4'
        elif file_type == 'thumbnails':
            return STATIC_FOLDER + str(travel_id) + '/thumbnails/thumbnail-%s.jpg' % str(filename_or_file_id)

    else:
        if file_type == 'images':
            return STATIC_FOLDER + str(travel_id) + '/images'
        elif file_type == 'videos':
            return STATIC_FOLDER + str(travel_id) + '/videos'
        elif file_type == 'thumbnails':
            return STATIC_FOLDER + str(travel_id) + '/thumbnails'

def get_travel_folder_path(travel_id, filename_or_file_id= None, file_type='images'):
    if filename_or_file_id:
        if file_type == 'images':
            return VIDEOS_FOLDER + str(travel_id) + '/images/' + str(filename_or_file_id)
        elif file_type == 'videos':
            if '.mp4' in filename_or_file_id:
                return VIDEOS_FOLDER + str(travel_id) + '/videos/' + str(filename_or_file_id)
            else:
                return VIDEOS_FOLDER + str(travel_id) + '/videos/' + str(filename_or_file_id) + '.mp4'
        elif file_type == 'thumbnails':
            return VIDEOS_FOLDER + str(travel_id) + '/thumbnails/thumbnail-%s.jpg' % str(filename_or_file_id)

    else:
        if file_type == 'images':
            return VIDEOS_FOLDER + str(travel_id) + '/images'
        elif file_type == 'videos':
            return VIDEOS_FOLDER + str(travel_id) + '/videos'
        elif file_type == 'thumbnails':
            return VIDEOS_FOLDER + str(travel_id) + '/thumbnails'
        elif file_type == 'root':
            return VIDEOS_FOLDER + str(travel_id)

def upload_file_to_database(file_path, static_path , filename, travel_id, stop_id):
    print("Adding file {0} to database".format(file_path))
    #travel_id = Stop.get_by_id(stop_id).travel_id

    if (get_file_extension(file_path) in IMAGE_EXTENSIONS):
        # read the image data using PIL
        lat, long, created_date = get_image_tags(file_path, filename)
        print(created_date)
        file_id = str(uuid.uuid4()) 
        file_thumbnail_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename)

        
        save_file_to_database(True, travel_id, stop_id, filename, lat, long, file_id, file_thumbnail_path, static_path, created_date=created_date)
        
    elif (get_file_extension(file_path) in VIDEO_EXTENSIONS):
        lat, long, created_date, duration = get_video_tags(file_path,filename)
        file_id = str(uuid.uuid4()) 
        
        abs_file_path = get_travel_folder_path(travel_id=travel_id, file_type='thumbnails')

        VideoUtils.save_video_thumbnail(file_path, abs_file_path, file_id)

        static_thumbnail_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=file_id, file_type='thumbnails')

        save_file_to_database(False,travel_id, stop_id, filename, lat, long, file_id, static_thumbnail_path, static_path, filename, True, created_date=created_date, video_duration=duration)
    else:
        print("File not supported")

def save_file_to_database(is_image, travel_id, stop_id, name, lat_coord, long_coord, file_id, file_thumbnail_path= None, file_path = None, filename=None, edit_video=False, created_date=None, video_duration=None):
    time_duration = 0

    if not is_image:
        if file_path is None:
            video_file_path  = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=filename, file_type='videos')
            file_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename, file_type='videos')
        if filename:
            video_file_path  = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=filename, file_type='videos')
            file_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename, file_type='videos')
            #if edit_video:
                #VideoEditor.AddTitleToVideo(video_file_path, filename, travel_id, name)

        if file_thumbnail_path is None:
            file_thumbnail_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename, file_type='thumbnails')
        
        if video_duration:
            if video_duration > 0:
                time_duration = video_duration
            else:
                time_duration = VideoUtils.get_video_info(video_file_path)

    address = GeoCodeUtils.reverse_latlong(lat_coord, long_coord)
    video = Wanderpi(id=file_id, name=name, lat=lat_coord, long=long_coord, file_thumbnail_path=file_thumbnail_path, travel_id=travel_id, stop_id=stop_id, address=address, time_duration=time_duration, file_path=file_path, is_image=is_image, has_been_edited=edit_video, created_date=created_date)
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

        for file in files_to_edit:
            file = Wanderpi.get_by_id(file)
            lat = json['lat'] if 'lat' in json.keys() else file.lat #if we have a new lat for the file on the, update it
            file.lat = lat
            long = json['long'] if 'long' in json.keys() else file.long #if we have a new long for the file on the, update it
            file.long = long
            name = json['name'] if 'name' in json.keys() else file.name #if we have a new name for the file on the, update it
            file.name = name
            
            file.address = GeoCodeUtils.reverse_latlong(lat, long)
            file.save()

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

@files_blu.route('/get_file_info/<string:file_id>')

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
        for key, file in request.files.items():
            if key.startswith('file'):
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    file_type = 'images' if get_file_extension(filename) in IMAGE_EXTENSIONS else 'videos'
                    path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=filename, file_type=file_type)
                    static_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename, file_type=file_type)
                    
                    if not os.path.isfile(path):     
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
    global  number_of_files
    print('Message from browser', data, counter, number_of_files)
    
    if counter < number_of_files:
        emit('update', 'File {0} successfully uploaded'.format(counter+1))
    

#@files_blu.route('/process_upload/<string:travel_id>', methods=['POST','GET'])
@socketio.on("process_upload_folder_update")
def process_upload(stop_id):
    #for every file in the uploads folder, upload it to the database
    travel_id = Stop.get_by_id(stop_id).travel_id
    upload_files = [f for f in listdir(UPLOAD_FOLDER) if isfile(join(UPLOAD_FOLDER, f))]
    if len(upload_files) > 0:
        for file in upload_files:
            emit('process_upload_folder_update', 'Uploading file {0}'.format(file))
            if (get_file_extension(file) in IMAGE_EXTENSIONS):
                #move file to images folder
                path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=file, file_type='images')
                static_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=file, file_type='images')
                if not os.path.isfile(path):
                    shutil.move(UPLOAD_FOLDER+file, path)
                    upload_file_to_database(path, static_path, file, travel_id,stop_id)
                    emit('process_upload_folder_update', 'File {0} successfully uploaded'.format(file.encode('utf-8')))

                else:
                    print("File already exists")
                    os.remove(join(UPLOAD_FOLDER, file))
                    emit('process_upload_folder_update', 'File {0} already exists'.format(file.encode('utf-8')))

                
            elif (get_file_extension(file) in VIDEO_EXTENSIONS):
                #move file to videos folder
                path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=file, file_type='videos')
                static_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=file, file_type='videos')
                if not os.path.isfile(path):
                    shutil.move(UPLOAD_FOLDER+file, path)
                    upload_file_to_database(path, static_path, file, travel_id,stop_id)
                    emit('process_upload_folder_update', 'File {0} successfully uploaded'.format(file.encode('utf-8')))

                else:
                    print("File already exists")
                    os.remove(join(UPLOAD_FOLDER, file))
                    emit('process_upload_folder_update', 'File {0} already exists'.format(file.encode('utf-8')))

            else:
                print("File not allowed")

        sleep(0.1)
        emit('process_upload_folder_update', "200")
    else:
        emit('process_upload_folder_update', "No files on the uploads folder")
        sleep(2)
        emit('process_upload_folder_update', "")
        emit('process_upload_folder_update', "200")

    return redirect("/stop/"+stop_id)


