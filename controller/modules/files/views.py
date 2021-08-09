from genericpath import isfile
from config import  UPLOAD_FOLDER, VIDEOS_FOLDER

from flask import Flask, json, jsonify, flash, request, redirect, render_template,send_from_directory,url_for
from werkzeug.utils import secure_filename

from controller.modules.files.video_utils import VideoUtils
from controller.models.models import Travel, Wanderpi
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

def upload_file_to_database(file_path, static_path , filename, travel_id):
    print("Adding file {0} to database".format(file_path))
    
    if (get_file_extension(file_path) in IMAGE_EXTENSIONS):
        # read the image data using PIL
        lat, long, created_date = get_image_tags(file_path, filename)
        print(created_date)
        file_id = str(uuid.uuid4()) 
        file_thumbnail_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename)

        
        save_file_to_database(True, travel_id, filename, lat, long, file_id, file_thumbnail_path, static_path, created_date=created_date)
        
    elif (get_file_extension(file_path) in VIDEO_EXTENSIONS):
        lat, long, created_date = get_video_tags(file_path,filename)
        file_id = str(uuid.uuid4()) 
        
        abs_file_path = get_travel_folder_path(travel_id=travel_id, file_type='thumbnails')

        VideoUtils.save_video_thumbnail(file_path, abs_file_path, file_id)

        static_thumbnail_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=file_id, file_type='thumbnails')

        save_file_to_database(False, travel_id, filename, lat, long, file_id, static_thumbnail_path, static_path, filename, True, created_date=created_date)
    else:
        print("File not supported")

def save_file_to_database(is_image, travel_id, name, lat_coord, long_coord, file_id, file_thumbnail_path= None, file_path = None, filename=None, edit_video=False, created_date=None):
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
        
        
        time_duration = VideoUtils.get_video_info(video_file_path)

    address = GeoCodeUtils.reverse_latlong(lat_coord, long_coord)
    video = Wanderpi(id=file_id, name=name, lat=lat_coord, long=long_coord, file_thumbnail_path=file_thumbnail_path, travel_id=travel_id, address=address, time_duration=time_duration, file_path=file_path, is_image=is_image, has_been_edited=edit_video, created_date=created_date)
    video.save()

    return "ok"

def delete_file_from_database(file_id):
    try:
        video = Wanderpi.get_by_id(file_id)
        travel_id = video.travel_id

        video.delete()

        return travel_id
    except:
        return "error"


@files_blu.route('/bulk_edit_files', methods=['POST'])
def bulk_edit_files():
    if request.method == 'POST':
        json = request.json

        files_to_edit = json['files_to_edit']
        lat = json['lat']
        long = json['long']

        for file in files_to_edit:
            file = Wanderpi.get_by_id(file)
            file.lat = lat
            file.long = long
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

        for file in files_to_delete:
            travel_id = delete_file_from_database(file)

        return jsonify({"error": 0})
    else:
        if request.referrer:
            return redirect(request.referrer)
        return redirect("/")

@files_blu.route('/delete_file/<string:file_id>')
def delete_file(file_id):
    travel_id = delete_file_from_database(file_id)
    
    travel = Travel.get_by_id(travel_id)
    
    if travel:
        return redirect('/travel/'+ travel.id)
    else:
        return redirect('/')  

@files_blu.route('/save_file/<string:file_id>/', methods=['GET', 'POST'])
def save_file(file_id): #todo get available video sources from database
    print("Saving file {0}".format(file_id))
    
    boolean = request.args.get('is_image')
    is_image = True if boolean == 'true' else False
    travel_id = request.args.get('travel_id')
    
    name = request.args.get('name', default=file_id)
    if len(name) == 0:
        name = file_id

    lat_coord = request.args.get('lat')
    long_coord = request.args.get('long')
    file_thumbnail_path = request.args.get('thumbnail_url', default=None)
    file_path = request.args.get('file_path', default=None)

    save_file_to_database(is_image, travel_id, name, lat_coord, long_coord, file_id, file_thumbnail_path, file_path, file_id)

    return jsonify(status_code = 200, message = "OK")

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

@files_blu.route('/uploads/<string:travel_id>/<string:filename>', methods=['GET', 'POST'])
def download_file(travel_id, filename):
    file_type = 'images' if get_file_extension(filename) in IMAGE_EXTENSIONS else 'videos'
    abs_file_path = get_travel_folder_path(travel_id=travel_id, file_type=file_type)
    file_path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=filename, file_type=file_type)
    
    if file_type == 'videos':
        video = Wanderpi.get_by_id(filename)

        if video and not video.has_been_edited:
            #VideoEditor.AddTitleToVideo(file_path, filename, travel_id, video.name)
            video.has_been_edited = True
            video.save()
    
    if '.' not in filename: 
        filename = file_path.split('/')[-1]
    
    return send_from_directory(abs_file_path, filename, as_attachment=True)

@files_blu.route('/upload/<string:travel_id>', methods=['POST','GET'])
def upload_file(travel_id):

    if request.method == 'POST':
        # print(request.form)
        
        # if len(request.files) == 0:
        #     flash('No file part')
        #     # {"error":0,"message":""}
        #     return  jsonify(error= 1, message="No files uploaded")

        # files = request.files
        # global counter, number_of_files
        # counter = 0
        # number_of_files = len(files)
        for key, file in request.files.items():
            if key.startswith('file'):
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    file_type = 'images' if get_file_extension(filename) in IMAGE_EXTENSIONS else 'videos'
                    path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=filename, file_type=file_type)
                    static_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=filename, file_type=file_type)
                    
                    if not os.path.isfile(path):     
                        file.save(path)
                        upload_file_to_database(path,static_path, filename, travel_id)
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
        
@socketio.on("update")
def update(data):
    global counter
    global  number_of_files
    print('Message from browser', data, counter, number_of_files)
    
    if counter < number_of_files:
        emit('update', 'File {0} successfully uploaded'.format(counter+1))
    

#@files_blu.route('/process_upload/<string:travel_id>', methods=['POST','GET'])
@socketio.on("process_upload_folder_update")
def process_upload(travel_id):
    #for every file in the uploads folder, upload it to the database
    
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
                    upload_file_to_database(path, static_path, file, travel_id)
                    emit('process_upload_folder_update', 'File {0} successfully uploaded'.format(file.encode('utf-8')))

                else:
                    print("File already exists")
                    emit('process_upload_folder_update', 'File {0} already exists'.format(file.encode('utf-8')))

                
            elif (get_file_extension(file) in VIDEO_EXTENSIONS):
                #move file to videos folder
                path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=file, file_type='videos')
                static_path = get_travel_folder_path_static(travel_id=travel_id, filename_or_file_id=file, file_type='videos')
                if not os.path.isfile(path):
                    shutil.move(UPLOAD_FOLDER+file, path)
                    upload_file_to_database(path, static_path, file, travel_id)
                    emit('process_upload_folder_update', 'File {0} successfully uploaded'.format(file.encode('utf-8')))

                else:
                    print("File already exists")
                    emit('process_upload_folder_update', 'File {0} already exists'.format(file.encode('utf-8')))

            else:
                print("File not allowed")

        sleep(0.1)
        emit('process_upload_folder_update', "200")
    else:
        emit('process_upload_folder_update', "No files on the uploads folder")
        sleep(2)
        emit('process_upload_folder_update', "")

    return redirect("/travel/"+travel_id)


