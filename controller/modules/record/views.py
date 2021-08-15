
from controller.modules.files.video_utils import VideoUtils
from controller.utils.video_editor import VideoEditor
from controller.models.models import Stop
import uuid
from controller.modules.files.views import get_travel_folder_path, get_travel_folder_path_static
from datetime import datetime

from controller.utils.camera import VideoCamera
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.record import record_blu
from flask import jsonify, request, redirect,Response
import os
import json

from flask_socketio import emit
from controller import socketio

#video_camera = None
global_frame = None
last_camera_index = 0
current_camera_index = 0
# {"index": 2, "deviceId" : "http://admin:manresa21@192.168.1.61/video.cgi?.mjpg", "deviceLabel" : "Jardin 2", "is_mjpg" : False, "is_picamera" : False, "auth_required": False, "username": "admin", "password": "manresa21" }
#video_camera_ids = [{"index": 0 ,"deviceId" : "0", "deviceLabel" : "Webcam", "is_mjpg" : False, "is_picamera" : False, "auth_required": False}, {"index": 1, "deviceId" : "http://admin:manresa21@192.168.1.61/video.cgi?.mjpg", "deviceLabel" : "Jardin 2", "is_mjpg" : False, "is_picamera" : False, "auth_required": False}]
video_camera_ids = []
video_camera_objs = []
travel_id = ""
temp_video_to_join = []

def load_json_file():
    global video_camera_ids
    if len(video_camera_ids) == 0:
        #open cameras.json file and load
        with open("./cameras.json", "r") as f:
            video_camera_ids = json.load(f)['video_camera_ids']
        print("Video sources loaded from json file")
    else:
        print("Video sources already loaded")

@record_blu.route('/get_available_video_sources', methods=['GET', 'POST'])
def get_available_video_sources(): #todo get available video sources from database
    #if video camera ids is not initialized load from json file
    load_json_file()
    
    return jsonify(devices = video_camera_ids)

def start_record(video_camera, file_type):
    global travel_id
    file_id = str(uuid.uuid4()) 
    destination_path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=file_id, file_type=file_type)
    video_camera.start_record(destination_path, file_id)
    return file_id

def init_camera(camera_index = last_camera_index):
    global last_camera_index
    global current_camera_index
    
    current_camera_index = camera_index

    if len(video_camera_objs) == 0:
        for camera in video_camera_ids:
            device_id = camera["deviceId"]
            if device_id.isnumeric():
                device_id = int(device_id)

            if camera["auth_required"]:
                video_camera_objs.append(VideoCamera(device_id, camera["is_mjpg"], camera["is_picamera"],  camera["username"], camera["password"]))
            else:
                video_camera_objs.append(VideoCamera(device_id, camera["is_mjpg"], camera["is_picamera"]))
            
        return video_camera_objs[camera_index]
    else:
        print("Cameras already initialized", camera_index, last_camera_index, len(video_camera_objs))
        if int(camera_index) != int(last_camera_index):
            print("Changed camera while recording")
            video_camera_temp = video_camera_objs[int(last_camera_index)]
            
            if video_camera_temp.is_record:
                video_camera_temp.cap.release()
                video_camera_temp.stop_record()
                temp_video_to_join.append(video_camera_temp.recording_thread.path)
                start_record(video_camera_objs[camera_index], 'videos')
            last_camera_index = camera_index
        

        return video_camera_objs[camera_index]

def video_stream(index):
    print("Opening camera with index {0}".format(index))

    global global_frame
    load_json_file()
    
    camera_id = video_camera_ids[int(index)]["deviceId"]

    video_camera = init_camera(int(index))

    if video_camera.cap:
        if video_camera.cap.isOpened():
            print("Camera {0} is opened".format(camera_id))
        else:
            print("Camera {0} is not opened".format(camera_id))
            device_id = video_camera.camera_id
            if isinstance(device_id, str) and device_id.isnumeric():
                device_id = int(device_id)
            video_camera.cap.open(video_camera.camera_id)
            

    
        while video_camera.cap.isOpened():
            frame = video_camera.get_frame()

            if frame is not None:
                global_frame = frame
                yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
            else:
                yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + global_frame + b'\r\n\r\n')
    else:
        while True:
            frame = video_camera.get_frame()

            if frame is not None:
                global_frame = frame
                yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
            else:
                yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + global_frame + b'\r\n\r\n')

@record_blu.route('/video_feed/<string:camera_id>/')
def video_feed(camera_id):
    return Response(video_stream(camera_id),
                    mimetype='multipart/x-mixed-replace; boundary=frame')



@record_blu.route('/record_status', methods=['POST'])
def record_status():
    global current_camera_index
    global travel_id

    video_camera = video_camera_objs[current_camera_index]

    # if video_camera is None:
    #     video_camera = init_camera()
    #     video_camera = video_camera_objs[current_camera_index]
    
    json = request.get_json()

    status = json['status']
    stop_id  = json['stop_id']
    travel_id = Stop.get_by_id(stop_id).travel_id  
    boolean = json['is_image']
    is_image = True if boolean == 'true' else False
    file_type = 'images' if is_image else 'videos'  

    if status == "true":
        print("Start recording...")
        file_id_1 = request.args.get('file_id', default=None)

        if file_id_1:
            print("Deleting file that was not saved on database with id: {0}".format(file_id_1))
            p =  get_travel_folder_path(travel_id=travel_id, filename_or_file_id=file_id_1, file_type=file_type)
            if os.path.exists(p):
                os.remove(p)

        file_id= start_record(video_camera, file_type)

        return jsonify(result="started", file_id=file_id)
    else:
        print("Stop recording...")

        file_id = video_camera.stop_record()

        if file_id is None:
            return jsonify(result="failed", status_code=400)
        
        file_path = get_travel_folder_path(travel_id=travel_id, filename_or_file_id=file_id, file_type=file_type)
        abs_file_path = get_travel_folder_path(travel_id=travel_id, file_type='thumbnails')
        #static_file_path = get_travel_folder_path_static(travel_id=travel_id, file_type='thumbnails')
        
        if len(temp_video_to_join) > 0:
            temp_video_to_join.append(file_path)
            VideoEditor.JoinVideos(temp_video_to_join, file_id, file_path)

        lat = json['lat']
        lng = json['long']
        
        file_name = str(datetime.now()) + " at " + GeoCodeUtils.reverse_latlong(lat, lng)

        VideoUtils.save_video_thumbnail(file_path, abs_file_path, file_id)
        
        return jsonify(result="stopped", status_code=200, file_id=file_id, file_name=file_name, file_path=file_path)


@socketio.on("record_update")
def record_update(data):
    global current_camera_index
    video_camera = video_camera_objs[current_camera_index]
    if data == "start":
        if video_camera.recording_thread and video_camera.recording_thread.isRunning:
            emit('record_update', video_camera.recording_thread.video_time)
        else:
            emit('record_update', 'error')
    