from config import VIDEOS_FOLDER
from os import name

from flask import json, session, render_template, redirect, url_for, Response,request, jsonify
from controller.modules.home import home_blu

from controller.models.models import Wanderpi, Travel
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.utils.video_editor import VideoEditor

from datetime import *




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
    if travel:
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

@home_blu.route('/file/<path:id>')
def single_file(id):
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
        
    wanderpi = Wanderpi.get_by_id(id)
    return render_template("single_video_view.html", file=wanderpi)   


@home_blu.route('/record/<string:travel_id>')
def record(travel_id):
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))

    travel = Travel.get_by_id(travel_id)
    return render_template("record.html", travel=travel)


@home_blu.route('/latlong/<string:address>', methods=['GET', 'POST'])
def latlong(address):
    travel_id =  request.args.get('travel_id')
    if travel_id:
        travel = Travel.get_by_id(travel_id)
        print(travel.lat, travel.long)
        if travel.lat != "0" and travel.long != "0":
            print("Found travel with id {0} and cached lat and long".format(travel_id))
            return jsonify(lat=travel.lat, long=travel.long, status_code = 200, message = "OK")
        else:
            print("Travel with id {0} found in database but lat and long is not cached".format(travel_id))
            lat, lng = GeoCodeUtils.reverse_address(address)
            travel.lat = lat
            travel.long = lng
            travel.save()
            return jsonify(lat=lat, long=lng, status_code = 200, message = "OK")
    else:
        print("No travel id found")
        return jsonify(status_code = 400, message = "No travel id found")

