import re
import requests
from config import VIDEOS_FOLDER
import os

from flask import Flask, jsonify, flash, request, redirect, render_template
from werkzeug.utils import secure_filename
import exifread


from datetime import datetime
from controller.modules.files import video_utils
from controller.modules.files.video_utils import VideoUtils
from controller.models.models import Wanderpi
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.files import files_blu
from flask_socketio import emit, join_room, leave_room
from controller import socketio

import uuid
last_known_counter = 0
counter = 0
VIDEO_EXTENSIONS = set(['mp4'])
IMAGE_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])
# Allowed extension you can set your own
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif', 'mp4'])

def get_file_extension(filename):
    return filename.rsplit('.', 1)[1].lower()

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

#convert degree minute second to degree decimal
def dms_to_dd(dms):
    dd = float(dms[0]) + float(dms[1])/60 + float(dms[2])/3600
    return float(dd)

def get_lat_long_tags(path_name):
    f = open(path_name, 'rb')

    tags = exifread.process_file(f, stop_tag='GPS')
    
    lat = 0
    long = 0

    for tag in tags.keys():
        if tag == 'GPS GPSLatitude':
            lat = dms_to_dd(tags[tag].values)
        elif tag == 'GPS GPSLongitude':
            long = dms_to_dd(tags[tag].values)
    
    if lat == 0 and long == 0:
        lat = 0
        long = 0

    return lat, long

def upload_file_to_database(file_path, filename, travel_id):
    print("Adding file {0} to database".format(file_path))
    
    if (get_file_extension(file_path) in IMAGE_EXTENSIONS):
        # read the image data using PIL
        lat, long = get_lat_long_tags(file_path)
        file_id = str(uuid.uuid4()) 
        file_thumbnail_path = "/static/videos/%s" % str(filename)
        save_file_to_database(True, travel_id, filename, lat, long, file_id, file_thumbnail_path, file_path)
        
    elif (get_file_extension(file_path) in VIDEO_EXTENSIONS):
        lat, long = get_lat_long_tags(file_path)
        file_id = str(uuid.uuid4()) 
        file_thumbnail_path = VideoUtils.get_video_thumbnail(file_path, file_id)
        save_file_to_database(False, travel_id, filename, lat, long, file_id, file_thumbnail_path, file_path, filename)
    else:
        print("File not supported")

def save_file_to_database(is_image, travel_id, name, lat_coord, long_coord, file_id, file_thumbnail_path= None, file_path = None,  filename=None):
    time_duration = 0

    if not is_image:
        if file_path is None:
            video_file_path  = './controller/static/videos/' + str(file_id) + '.mp4'
            file_path = '/static/videos/' + str(file_id) + '.mp4'
        if filename:
            video_file_path  = './controller/static/videos/' + str(filename)
            file_path = '/static/videos/' + str(filename)

        if file_thumbnail_path is None:
            file_thumbnail_path = "/static/thumbnails/thumbnail-%s.jpg" % str(file_id)
        time_duration = VideoUtils.get_video_info(video_file_path)

    address = GeoCodeUtils.reverse_latlong(lat_coord, long_coord)
    video = Wanderpi(id=file_id, name=name, lat=lat_coord, long=long_coord, file_thumbnail_path=file_thumbnail_path, travel_id=travel_id, address=address, time_duration=time_duration, file_path=file_path, is_image=is_image)
    video.save()

    return "ok"

@files_blu.route('/delete_file/<string:file_id>')
def delete_file(file_id):
    video = Wanderpi.get_by_id(file_id)
    travel_id = video.travel_id
    
    #os.remove(video.file_path)

    Wanderpi.delete(file_id)

    return redirect("/travel/"+travel_id, code=302)

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

    save_file_to_database(is_image, travel_id, name, lat_coord, long_coord, file_id, file_thumbnail_path, file_path)

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

@files_blu.route('/upload/<string:travel_id>', methods=['POST','GET'])
def upload_file(travel_id):
    if request.method == 'POST':
        print(request.form)
        
        if len(request.files) == 0:
            flash('No file part')
            # {"error":0,"message":""}
            return  jsonify(error= 1, message="No files uploaded")

        files = request.files
        global counter, last_known_counter
        counter = len(files)
        last_known_counter = counter
        for key in files:
            file = files[key]
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                path = os.path.join(VIDEOS_FOLDER, filename)
                file.save(path)

                upload_file_to_database(path, filename, travel_id)
                
                counter = counter - 1
                # flash('File(s) successfully uploaded')
            else:
                flash('File not allowed')
                #return redirect(request.referrer)

        #return redirect("/travel/"+travel_id, code=302)
        return jsonify(error= 0, message="File(s) successfully uploaded")
    else:
        if request.referrer:
            return redirect(request.referrer)
        return redirect("/travel/"+travel_id)
        
@socketio.on("update")
def update(data):
    global counter
    global  last_known_counter
    print('Message from browser', data, counter, last_known_counter)
    
    if counter < last_known_counter:
        emit('update', 'File {0} successfully uploaded'.format(last_known_counter))
        last_known_counter = counter
    
