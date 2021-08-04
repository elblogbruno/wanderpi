
from datetime import datetime
from controller.utils.video_editor import VideoEditor
from controller.utils.camera import VideoCamera
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.record import record_blu
from flask import jsonify, request, redirect,Response
from config import VIDEOS_FOLDER
import os


#video_camera = None
global_frame = None
last_camera_index = 0
current_camera_index = 0
# {"index": 2, "deviceId" : "http://admin:manresa21@192.168.1.61/video.cgi?.mjpg", "deviceLabel" : "Jardin 2", "is_mjpg" : False, "is_picamera" : False, "auth_required": False, "username": "admin", "password": "manresa21" }
video_camera_ids = [{"index": 0 ,"deviceId" : "0", "deviceLabel" : "Webcam", "is_mjpg" : False, "is_picamera" : False, "auth_required": False}, {"index": 1, "deviceId" : "http://admin:manresa21@192.168.1.61/video.cgi?.mjpg", "deviceLabel" : "Jardin 2", "is_mjpg" : False, "is_picamera" : False, "auth_required": False}]
video_camera_objs = []

temp_video_to_join = []

@record_blu.route('/get_available_video_sources', methods=['GET', 'POST'])
def get_available_video_sources(): #todo get available video sources from database
    return jsonify(devices = video_camera_ids)

def init_camera(camera_index = last_camera_index):
    global last_camera_index
    global current_camera_index
    
    current_camera_index = camera_index

    if len(video_camera_objs) == 0:
        for camera in video_camera_ids:
            
            if camera["deviceId"].isnumeric():
                camera["deviceId"] = int(camera["deviceId"])

            if camera["auth_required"]:
                video_camera_objs.append(VideoCamera(camera["deviceId"], camera["is_mjpg"], camera["is_picamera"],  camera["username"], camera["password"]))
            else:
                video_camera_objs.append(VideoCamera(camera["deviceId"], camera["is_mjpg"], camera["is_picamera"]))
            
        return video_camera_objs[camera_index]
    else:
        print("Cameras already initialized", camera_index, last_camera_index, len(video_camera_objs))
        if int(camera_index) != int(last_camera_index):
            print("Changed camera while recording")
            video_camera_temp = video_camera_objs[int(last_camera_index)]
            
            if video_camera_temp.is_record:
                video_camera_temp.stop_record()
                temp_video_to_join.append(video_camera_temp.recording_thread.path)

            last_camera_index = camera_index
        
       
        return video_camera_objs[camera_index]

def video_stream(index):
    print("Opening camera with index {0}".format(index))

    global global_frame

    camera_id = video_camera_ids[int(index)]["deviceId"]
    
    video_camera = init_camera(int(index))

    if video_camera.cap:
        if video_camera.cap.isOpened():
            print("Camera {0} is opened".format(camera_id))
        else:
            print("Camera {0} is not opened".format(camera_id))
            video_camera.cap.open(camera_id)

    
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

    video_camera = video_camera_objs[current_camera_index]

    # if video_camera is None:
    #     video_camera = init_camera()
    #     video_camera = video_camera_objs[current_camera_index]
    
    json = request.get_json()

    print(json)

    status = json['status']

    if status == "true":
        print("Start recording...")
        video_id_1 = request.args.get('video_id', default=None)

        if video_id_1:
            print("Deleting video that was not saved on database with id: {0}".format(video_id_1))
            p = VIDEOS_FOLDER + "/" + video_id_1 + ".mp4"
            if os.path.exists(p):
                os.remove(p)

        video_id = video_camera.start_record()
        return jsonify(result="started", video_id=video_id)
    else:
        print("Stop recording...")
        lat = json['lat']
        lng = json['long']

        video_id = video_camera.stop_record()

        if video_id is None:
            return jsonify(result="failed", status_code=400)

        if len(temp_video_to_join) > 0:
            p = '/controller/static/videos/' + str(video_id) + '.mp4'
            temp_video_to_join.append(p)
            #video_id = video_id + "joined"
            print(temp_video_to_join)
            VideoEditor.JoinVideos(temp_video_to_join, video_id)

        video_name = str(datetime.now()) + " at " + GeoCodeUtils.reverse_latlong(lat, lng)

        VideoEditor.AddTitleToVideo(video_camera.recording_thread.path, video_id, video_name)

        return jsonify(result="stopped", status_code=200, video_id=video_id, video_name=video_name)