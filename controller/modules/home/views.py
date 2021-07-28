from app import Wanderpi
from os import name
from config import UPLOAD_FOLDER
from flask import json, session, render_template, redirect, url_for, Response,request, jsonify,send_from_directory
from controller.modules.home import home_blu
from controller.utils.camera import VideoCamera

video_camera_ids = [{"deviceId" : 0, "deviceLabel" : "Webcam"}, {"deviceId" : 1, "deviceLabel" : "Webcam1"}]

video_camera = None
global_frame = None

@home_blu.route('/')
def index():
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
        
    wanderpis = Wanderpi.get_all()
    return render_template("test.html", wanderpis=wanderpis)   

# 主页
@home_blu.route('/record')
def record():
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
    return render_template("record.html")

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
    

# 获取视频流
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


# 视频流
@home_blu.route('/video_feed/<string:camera_id>/')
def video_feed(camera_id):
    # 模板渲染
    username = session.get("username")
    if not username:
        return redirect(url_for("user.login"))
    return Response(video_stream(camera_id),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

# 录制状态
@home_blu.route('/record_status', methods=['POST'])
def record_status():
    global video_camera

    if video_camera is None:
        video_camera = init_camera()
    
    json = request.get_json()

    status = json['status']

    if status == "true":
        print("Start recording...")
        video_id = video_camera.start_record()
        return jsonify(result="started", video_id=video_id)
    else:
        print("Stop recording...")
        video_id = video_camera.stop_record()
        return jsonify(result="stopped", video_id=video_id)

@home_blu.route('/uploads/<path:filename>', methods=['GET', 'POST'])
def download_file(filename):
    return send_from_directory(directory=UPLOAD_FOLDER, path=filename, as_attachment=True)


@home_blu.route('/get_available_video_sources', methods=['GET', 'POST'])
def get_available_video_sources(): #todo get available video sources from database
    return jsonify(devices = video_camera_ids)

@home_blu.route('/save_video/<string:video_id>/', methods=['GET', 'POST'])
def save_video(video_id): #todo get available video sources from database
    print("Saving video {0}".format(video_id))
    
    wanderpi = Wanderpi(id=video_id, name="a", lat="a", long="a")
    wanderpi.save()

    return jsonify(devices = video_camera_ids)


