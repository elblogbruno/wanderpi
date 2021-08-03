
from controller.modules.video.video_utils import VideoUtils
from controller.models.models import Wanderpi
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.video import video_blu
from flask import jsonify, request, redirect

@video_blu.route('/delete_video/<string:id>')
def delete_video(id):
    video = Wanderpi.get_by_id(id)
    travel_id = video.travel_id
    Wanderpi.delete(id)

    return redirect("/travel/"+travel_id, code=302)

@video_blu.route('/save_video/<string:video_id>/', methods=['GET', 'POST'])
def save_video(video_id): #todo get available video sources from database
    print("Saving video {0}".format(video_id))
    
    travel_id = request.args.get('travel_id')
    name = request.args.get('name', default=video_id)
    if len(name) == 0:
        name = video_id

    lat_coord = request.args.get('lat')
    long_coord = request.args.get('long')
    video_location_path  = '/controller/static/videos/' + str(video_id) + '.mp4'
    thumbnail_url = "thumbnail-%s.jpg" % str(video_id)

    address = GeoCodeUtils.reverse_latlong(lat_coord, long_coord)
    time_duration = VideoUtils.get_video_info(video_location_path) 

    video = Wanderpi(id=video_id, name=name, lat=lat_coord, long=long_coord, thumbnail_url=thumbnail_url, travel_id=travel_id, address=address, time_duration=time_duration, video_location_path=video_location_path)
    video.save()

    return jsonify(status_code = 200, message = "OK")

@video_blu.route('/get_video_info/<string:video_id>', methods=['GET', 'POST'])
def get_video_info(video_id):
    if video_id:
        video = Wanderpi.get_by_id(video_id)
        video_info = VideoUtils.get_video_info(video.video_location_path)
        
        return jsonify(video_id=video_id, video_info=video_info, status_code = 200, message = "OK")
    else:
        print("No travel id found")
        return jsonify(status_code = 400, message = "No travel id found")
