from config import UPLOAD_FOLDER
from flask import session, render_template, redirect, url_for, Response,request, jsonify,send_from_directory
from controller.modules.home import home_blu
from controller.utils.camera import VideoCamera


video_camera = None
global_frame = None

@home_blu.route('/test')
def test():
    # 模板渲染
    return render_template("test.html")
# 主页
@home_blu.route('/')
def index():
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
    return render_template("record.html")

def init_camera():
    global video_camera
    if video_camera is None:
        print("Camera has not been initialized. Initializing...")
        print("Initialized video camera")
        a = "rtsp://192.168.1.10:554/user=admin_password=VyJdSdKg_channel=0_stream=1.sdp?real_stream"
        return VideoCamera()  
    else:
        print("Video Camera Object exists")
        
        if video_camera.cap.isOpened():
            video_camera.cap.release()
            # video_camera.stop_record()

        return video_camera
    

# 获取视频流
def video_stream():
    global video_camera
    global global_frame
    video_camera = init_camera()
    
    
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
@home_blu.route('/video_viewer')
def video_viewer():
    # 模板渲染
    username = session.get("username")
    if not username:
        return redirect(url_for("user.login"))
    return Response(video_stream(),
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

