from os import name
from config import VIDEOS_FOLDER
from flask import json, session, render_template, redirect, url_for, Response,request, jsonify,send_from_directory
from controller.modules.home import home_blu
from controller.utils.camera import VideoCamera
from controller.models.models import Wanderpi, Travel

from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.utils.video_editor import VideoEditor

from datetime import *
import os
import uuid

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
        
    travels = Travel.get_all()
    
    return render_template("index.html", travels=travels)   

@home_blu.route('/travel/<string:travel_id>')
def travel(travel_id):
    print(travel_id)
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
        
    travel = Travel.get_by_id(travel_id)
    wanderpis = travel.get_all_wanderpis()

    return render_template("travel_view.html", wanderpis=wanderpis, travel=travel)  

@home_blu.route('/global_map/<string:travel_id>')
def global_map(travel_id):
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
        
    print(travel_id)
    travel = Travel.get_by_id(travel_id)
    wanderpis = travel.get_all_wanderpis()
    return render_template("global_map.html", wanderpis=wanderpis, travel=travel)   

@home_blu.route('/delete_travel/<string:id>')
def delete_travel(id):
    print(id)
    travel = Travel.get_by_id(id)
    travel.delete_all_wanderpis()
    Travel.delete(id)
    return redirect("/", code=302)

@home_blu.route('/delete_video/<string:id>')
def delete_video(id):
    print(id)
    Wanderpi.delete(id)
    return redirect("/", code=302)

@home_blu.route('/video/<path:id>')
def single_video(id):
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
        
    wanderpi = Wanderpi.get_by_id(id)
    return render_template("single-video-view.html", video=wanderpi)   

@home_blu.route('/record/<string:travel_id>')
def record(travel_id):
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))

    travel = Travel.get_by_id(travel_id)
    return render_template("record.html", travel=travel)

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

@home_blu.route('/video_feed/<string:camera_id>/')
def video_feed(camera_id):
    username = session.get("username")
    if not username:
        return redirect(url_for("user.login"))
    return Response(video_stream(camera_id),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@home_blu.route('/record_status', methods=['POST'])
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

@home_blu.route('/uploads/<path:filename>', methods=['GET', 'POST'])
def download_file(filename):
    return send_from_directory(VIDEOS_FOLDER, filename, as_attachment=True)

@home_blu.route('/get_available_video_sources', methods=['GET', 'POST'])
def get_available_video_sources(): #todo get available video sources from database
    return jsonify(devices = video_camera_ids)

@home_blu.route('/save_video/<string:video_id>/', methods=['GET', 'POST'])
def save_video(video_id): #todo get available video sources from database
    print("Saving video {0}".format(video_id))
    
    name = request.args.get('name', default=video_id)
    if name == "":
        name = video_id
    lat_coord = request.args.get('lat')
    long_coord = request.args.get('long')

    adress = GeoCodeUtils.reverse_latlong(lat_coord, long_coord)

    travel_id = request.args.get('travel_id')
    thumbnail_url = "thumbnail-%s.jpg" % str(video_id)
        
    print(name, lat_coord, long_coord, thumbnail_url)

    wanderpi = Wanderpi(id=video_id, name=name, lat=lat_coord, long=long_coord, thumbnail_url=thumbnail_url, travel_id=travel_id, adress=adress)
    wanderpi.save()

    return jsonify(status_code = 200, message = "OK")

def toDate(dateString):
    print(dateString)
    return datetime.strptime(dateString, "%Y-%m-%dT%H:%M") #example datetime input 2021-07-01T13:45

@home_blu.route('/save_travel/', methods=['GET', 'POST'])
def save_travel(): #todo get available video sources from database
    print("Saving travel")
    
    name = request.args.get('name')
    destination = request.args.get('destination')
    start_date = request.args.get('start_date', type=toDate)
    end_date = request.args.get('end_date', type=toDate)
    travel_id = str(uuid.uuid4()) 

    travel = Travel(id=travel_id, name=name, lat="0", long="0", destination=destination, start_date=start_date, end_date=end_date)
    travel.save()

    return jsonify(status_code = 200, message = "OK")

@home_blu.route('/latlong/<string:adress>', methods=['GET', 'POST'])
def latlong(adress):
    travel_id =  request.args.get('travel_id')
    if travel_id:
        travel = Travel.get_by_id(travel_id)
        print(travel.lat, travel.long)
        if travel.lat != "0" and travel.long != "0":
            print("Found travel with id {0} and cached lat and long".format(travel_id))
            return jsonify(lat=travel.lat, long=travel.long, status_code = 200, message = "OK")
        else:
            print("Travel with id {0} found in database but lat and long is not cached".format(travel_id))
            lat, lng = GeoCodeUtils.reverse_adress(adress)
            travel.lat = lat
            travel.long = lng
            travel.save()
            return jsonify(lat=lat, long=lng, status_code = 200, message = "OK")
    else:
        print("No travel id found")
        return jsonify(status_code = 400, message = "No travel id found")
