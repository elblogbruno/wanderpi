from controller.models.models import Travel
from controller.modules.home.geocode_utils import GeoCodeUtils
from controller.modules.travel import travel_blu
from flask import redirect, request, jsonify
from datetime import *
import uuid

@travel_blu.route('/delete_travel/<string:id>')
def delete_travel(id):
    travel = Travel.get_by_id(id)
    travel.delete_all_wanderpis()
    Travel.delete(id)
    return redirect("/", code=302)

def toDate(dateString):
    print(dateString)
    return datetime.strptime(dateString, "%Y-%m-%d") #example datetime input 2021-07-01

@travel_blu.route('/save_travel/', methods=['GET', 'POST'])
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
