from os import name

from flask import json,jsonify, request
from controller.modules.api import api_blu

from controller.models.models import Wanderpi, Travel, Stop, Note
from controller.modules.home.pagination import Pagination
from controller.modules.travel.views import search_wanderpis
from datetime import *

import jinja2.exceptions

per_page=5  

@api_blu.route('/api/get_available_travels')
def get_available_travels():  
    travels = Travel.get_all_as_json()
    return jsonify(travels=travels)

@api_blu.route('/api/get_available_stops/<string:travel_id>')
def get_available_stops(travel_id):  
    travel = Travel.get_by_id(travel_id)
    
    if travel:
        stops = travel.get_all_stops_as_json()

    return jsonify(travel=travel.as_dict(), stops=stops)

@api_blu.route('/api/travel_calendar/<string:travel_id>')
def travel_calendar(travel_id):
    print(travel_id)
    notes_js = []
    travel = Travel.get_by_id(travel_id)
    if travel:
        notes = travel.get_all_notes_as_json()
        
        for note_json in notes:
            note = Note.get_by_id(note_json['id'])
            
            if note:
                inputs = note.get_all_input_as_json_dumps()
            else:
                inputs = []
                
            dic = {
                "note": note_json,
                "inputs": inputs,
            }

            notes_js.append(dic)

        total_price = round(travel.get_total_price(), 3)
    else:
        notes = []
        notes_js = []
    
    return jsonify(travel=travel.as_dict(), notes=notes_js, total_price=total_price)


@api_blu.route('/api/stop/<string:stop_id>/', defaults={'page': None})
@api_blu.route('/api/stop/<string:stop_id>/<int:page>/')
def stop(stop_id, page):
    print(stop_id)
    global per_page

    new_per_page = request.args.get('per_page', default=None, type=int)
    if new_per_page:
        per_page = new_per_page

    query = request.args.get('query', default=None, type=str)
    stop = Stop.get_by_id(stop_id)
    wanderpis = []
    travel = None
    
    if stop:
        travel = Travel.get_by_id(stop.travel_id)
        if not query:
            wanderpis = stop.get_all_wanderpis_as_json()
        else:
            wanderpis_list = search_wanderpis(stop, query)
            wanderpis = [wanderpi.as_dict() for wanderpi in wanderpis_list ]
    
    if not page:
        page = 1

    total_count = len(wanderpis)
    pagination = Pagination(page, per_page=per_page, total_count=total_count)
    current_count = page*per_page

    wanderpis = wanderpis[(page-1)*per_page:page*per_page]
    if travel:
        if query:
            return jsonify(wanderpis=wanderpis,pages=pagination.pages, has_prev=pagination.has_prev, has_next=pagination.has_next, prev_num=pagination.prev_num, next_num=pagination.next_num, total_count=total_count, per_page=per_page, current_count=current_count, search_term=query)  

        return jsonify(wanderpis=wanderpis,pages=pagination.pages, has_prev=pagination.has_prev, has_next=pagination.has_next, prev_num=pagination.prev_num, next_num=pagination.next_num, total_count=total_count, per_page=per_page, current_count=current_count)  
    else:
        return jsonify(error="incorrect stop id")





