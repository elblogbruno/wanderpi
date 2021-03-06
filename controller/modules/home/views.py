from os import name

from flask import json, session, render_template, redirect, url_for, Response,request, jsonify,send_from_directory
from controller.modules.home import home_blu

from controller.models.models import Wanderpi, Travel, Stop
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.utils.video_editor import VideoEditor
from controller.modules.home.pagination import Pagination
from controller.modules.travel.views import search_wanderpis
from datetime import *

import jinja2.exceptions
import geopy

per_page=5

@home_blu.route('/favicon.ico')
def favicon():
    return send_from_directory('./controller/static',
                          'favicon.ico',mimetype='image/vnd.microsoft.icon')

@home_blu.route('/')
def index():
    # 模板渲染
    # username = session.get("username")
    # if not username:
    #     session["initialized"] = False
    #     return redirect(url_for("user.login"))
        
    travels = Travel.get_all()
    
    return render_template("index.html", travels=travels)   

@home_blu.route('/travel/<string:travel_id>')
def travel(travel_id):
    print(travel_id)
    # username = session.get("username")
    # if not username:
    #     session["initialized"] = False
    #     return redirect(url_for("user.login"))

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
    # username = session.get("username")
    # if not username:
    #     session["initialized"] = False
    #     return redirect(url_for("user.login"))

    # try:     
    travel = Travel.get_by_id(travel_id)
    if travel:
        notes = travel.get_all_notes()
        total_price = round(travel.get_total_price(), 3)
    else:
        notes = []
    session["current_travel_id"] = travel_id

    current_day = date.today()
    return render_template("travel_calendar.html", travel=travel, notes=notes, total_price=total_price, current_day=current_day)  
    # except:
    #     return redirect(url_for("home.index"))

@home_blu.route('/stop/<string:stop_id>/', defaults={'page': None})
@home_blu.route('/stop/<string:stop_id>/<int:page>/')
def stop(stop_id, page):
    print(stop_id)
    global per_page
    # username = session.get("username")
    # if not username:
    #     session["initialized"] = False
    #     return redirect(url_for("user.login"))
    
    query = request.args.get('query', default=None, type=str)
    stop = Stop.get_by_id(stop_id)
    wanderpis = []
    travel = None
    if stop:
        travel = Travel.get_by_id(stop.travel_id)
        if not query:
            wanderpis = stop.get_all_wanderpis()
        else:
            wanderpis = search_wanderpis(stop, query)
    
    session["current_stop_id"] = stop_id

    
    if not page:
        page = 1

    total_count = len(wanderpis)

    #sort wanderpis by date
    #wanderpis = sorted(wanderpis, key=lambda x: x.created_date)

    pagination = Pagination(page, per_page=per_page, total_count=total_count)
    current_count = page*per_page

    wanderpis = wanderpis[(page-1)*per_page:page*per_page]
    if travel:
        if query:
            return render_template("stops_view.html", wanderpis=wanderpis, stop=stop, travel=travel, pagination=pagination, total_count=total_count, per_page=per_page, search_term=query, current_count=current_count)  

        return render_template("stops_view.html", wanderpis=wanderpis, stop=stop, travel=travel, pagination=pagination, total_count=total_count, per_page=per_page, current_count=current_count)  
    else:
        return redirect(url_for("home.index"))

@home_blu.route('/slide_view/<string:stop_id>/', defaults={'page': None})
@home_blu.route('/slide_view/<string:stop_id>/<int:page>/')
def slide_view(stop_id, page):
    print(stop_id)
    global per_page

    stop = Stop.get_by_id(stop_id)
    travel = None
    
    if stop:
        wanderpis = stop.get_all_wanderpis()
        travel = Travel.get_by_id(stop.travel_id)
    else:
        travel = Travel.get_by_id(stop_id)
        wanderpis = travel.get_all_wanderpis()
    
    if not page:
        page = 1

    total_count = len(wanderpis)

    #sort wanderpis by date
    #wanderpis = sorted(wanderpis, key=lambda x: x.created_date)

    pagination = Pagination(page, per_page=per_page, total_count=total_count)

    current_count = page*per_page

    wanderpis = wanderpis[(page-1)*per_page:page*per_page]
    if stop:
        return render_template("slide_view.html", wanderpis=wanderpis, stop=stop, pagination=pagination, total_count=total_count, per_page=per_page, first_lat=wanderpis[0].lat, first_long=wanderpis[0].long, current_count=current_count)  
    
    return render_template("slide_view.html", wanderpis=wanderpis, travel=travel, pagination=pagination, total_count=total_count, per_page=per_page, first_lat=wanderpis[0].lat, first_long=wanderpis[0].long, current_count=current_count)  


@home_blu.route('/global_map/<string:id>/', defaults={'page': None})
@home_blu.route('/global_map/<string:id>/<int:page>/')
def global_map(id, page):
    print(id)
    global per_page
    
    stop = Stop.get_by_id(id)
    travel = None
    
    if stop:
        wanderpis = stop.get_all_wanderpis()
        travel = Travel.get_by_id(stop.travel_id)
    else:
        travel = Travel.get_by_id(id)
        wanderpis = travel.get_all_wanderpis()

    if not page:
        page = 1

    total_count = len(wanderpis)

    #sort wanderpis by date
    #wanderpis = sorted(wanderpis, key=lambda x: x.created_date)

    pagination = Pagination(page, per_page=per_page, total_count=total_count)

    wanderpis = wanderpis[(page-1)*per_page:page*per_page]
    if stop:
        return render_template("global_map.html", wanderpis=wanderpis, stop=stop, travel=travel, pagination=pagination, total_count=total_count, per_page=per_page)  
    return render_template("global_map.html", wanderpis=wanderpis, travel=travel, pagination=pagination, total_count=total_count, per_page=per_page)  
    


@home_blu.route('/file/<path:id>')
def single_file(id):
    # username = session.get("username")
    # if not username:
    #     session["initialized"] = False
    #     return redirect(url_for("user.login"))

    try: 
        wanderpi = Wanderpi.get_by_id(id)
        stop = Stop.get_by_id(wanderpi.stop_id)
        travel = Travel.get_by_id(wanderpi.travel_id)
        # if wanderpi.is_image:
        #     wanderpi.file_path = wanderpi.file_path.replace('/mnt', '')

        return render_template("single_file_view.html", file=wanderpi, stop=stop, travel=travel)   
    except jinja2.exceptions.UndefinedError as e:
        print(str(e))
        return redirect(url_for("home.index"))

@home_blu.route('/record/<string:stop_id>')
def record(stop_id):
    # 模板渲染
    # username = session.get("username")
    # if not username:
    #     session["initialized"] = False
    #     return redirect(url_for("user.login"))

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

