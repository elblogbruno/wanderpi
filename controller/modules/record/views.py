
from datetime import datetime
from controller.utils.video_editor import VideoEditor
from controller.utils.camera import VideoCamera
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.record import record_blu
from flask import jsonify, request, redirect,Response
from config import VIDEOS_FOLDER
import os


video_camera = None
global_frame = None

video_camera_ids = [{"deviceId" : 0, "deviceLabel" : "Webcam"}, {"deviceId" : 1, "deviceLabel" : "Webcam1"}]


@record_blu.route('/get_available_video_sources', methods=['GET', 'POST'])
def get_available_video_sources(): #todo get available video sources from database
    return jsonify(devices = video_camera_ids)

def init_camera(camera_id):
    global video_camera
    if video_camera is None:
        print("Camera {0} has not been initialized. Initializing...".format(camera_id))
        print("Initialized video camera")
        
        if camera_id.isnumeric():
            camera_id = int(camera_id)

        return VideoCamera(camera_id)  
    else:
        print("Video Camera Object exists")
        
        # if video_camera.cap.isOpened():
        #     video_camera.cap.release()
            # video_camera.stop_record()

        return video_camera

def video_stream(camera_id):
    global video_camera
    global global_frame
    video_camera = init_camera(camera_id)
    
    
    while video_camera.cap.isOpened():
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
    global video_camera

    if video_camera is None:
        video_camera = init_camera()
    
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
        
        video_name = str(datetime.now()) + " at " + GeoCodeUtils.reverse_latlong(lat, lng)

        VideoEditor.AddTitleToVideo(video_camera.recordingThread.path_rel, video_name)

        return jsonify(result="stopped", video_id=video_id, video_name=video_name)