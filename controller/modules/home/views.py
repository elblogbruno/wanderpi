from os import name

from flask import json, session, render_template, redirect, url_for, Response,request, jsonify,send_from_directory
from controller.modules.home import home_blu

from controller.models.models import Wanderpi, Travel, Stop
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.utils.video_editor import VideoEditor

from datetime import *

import jinja2.exceptions
import geopy

@home_blu.route('/favicon.ico')
def favicon():
    return send_from_directory('./controller/static',
                          'favicon.ico',mimetype='image/vnd.microsoft.icon')

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

    #try:     
    travel = Travel.get_by_id(travel_id)
    if travel:
        stops = travel.get_all_stops()
    
    session["current_travel_id"] = travel_id

    return render_template("travel_view.html", stops=stops, travel=travel)  
    # except:
    #     return redirect(url_for("home.index"))

@home_blu.route('/travel_calendar/<string:travel_id>')
def travel_calendar(travel_id):
    print(travel_id)
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))

    # try:     
    travel = Travel.get_by_id(travel_id)
    if travel:
        notes = travel.get_all_notes()
        total_price = travel.get_total_price()
    else:
        notes = []
    session["current_travel_id"] = travel_id
    return render_template("travel_calendar.html", travel=travel, notes=notes, total_price=total_price)  
    # except:
    #     return redirect(url_for("home.index"))

@home_blu.route('/stop/<string:stop_id>')
def stop(stop_id):
    print(stop_id)
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))

    #try:     
    stop = Stop.get_by_id(stop_id)
    travel = Travel.get_by_id(stop.travel_id)
    if stop:
        wanderpis = stop.get_all_wanderpis()
    
    session["current_stop_id"] = stop_id

    return render_template("stops_view.html", wanderpis=wanderpis, stop=stop, travel=travel)  
    # except:
    #     return redirect(url_for("home.index"))

@home_blu.route('/global_map/<string:travel_id>')
def global_map(travel_id):
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))
        
    try:   
        travel = Travel.get_by_id(travel_id)
        wanderpis = travel.get_all_wanderpis()
        return render_template("global_map.html", wanderpis=wanderpis, travel=travel)
    except:
        return redirect(url_for("home.index"))   

@home_blu.route('/file/<path:id>')
def single_file(id):
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))

    try: 
        wanderpi = Wanderpi.get_by_id(id)
        stop = Stop.get_by_id(wanderpi.stop_id)
        travel = Travel.get_by_id(wanderpi.travel_id)
        
        return render_template("single_video_view.html", file=wanderpi, stop=stop, travel=travel)   
    except jinja2.exceptions.UndefinedError as e:
        print(str(e))
        return redirect(url_for("home.index"))

@home_blu.route('/record/<string:stop_id>')
def record(stop_id):
    # 模板渲染
    username = session.get("username")
    if not username:
        session["initialized"] = False
        return redirect(url_for("user.login"))

    #try:
    stop = Stop.get_by_id(stop_id)
    return render_template("record.html", stop=stop)
    # except:
    #     return redirect(url_for("home.index"))


@home_blu.route('/latlong/<string:address>', methods=['GET', 'POST'])
def latlong(address):
    travel_id =  request.args.get('travel_id')
    if travel_id:
        travel = Travel.get_by_id(travel_id)
        if not travel:
            travel = Stop.get_by_id(travel_id)

        print(travel.lat, travel.long)
        if travel.lat != "0" and travel.long != "0":
            print("Found travel with id {0} and cached lat and long".format(travel_id))
            return jsonify(lat=travel.lat, long=travel.long, status_code = 200, message = "OK")
        else:
            print("Travel with id {0} found in database but lat and long is not cached".format(travel_id))
            try: 
                lat, lng = GeoCodeUtils.reverse_address(address)
                travel.lat = lat
                travel.long = lng
                travel.save()
                return jsonify(lat=lat, long=lng, status_code = 200, message = "OK")
            except geopy.exc.GeocoderUnavailable as e:
                return jsonify(lat=0, long=0, status_code = 200, message = "OK")

                
    else:
        print("No travel id found")
        return jsonify(status_code = 400, message = "No travel id found")

