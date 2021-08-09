//having a list of coordenates, calculates total distance
function getDistance(list_of_points) {
    var distance = 0;
    for (var i = 0; i < list_of_points.length - 1; i++) {
        distance += getDistanceBetweenPoints(list_of_points[i].lat, list_of_points[i].lng, list_of_points[i + 1].lat, list_of_points[i + 1].lng);
    }
    return Number((distance).toFixed(1)); // 6.7;
}

function getDistanceBetweenPoints(lat1, long1, lat2, long2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1);  // deg2rad below
    var dLon = deg2rad(long2 - long1);
    var a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
}

function deg2rad(p){
    return p * (Math.PI/180);
}

var acLatlong = {};

function loadDistanceListFromWanderpis(lat, long, travel_id)
{
    // if keys are not set, then we are starting a new map
    if (!acLatlong.hasOwnProperty(travel_id)) 
    {
        acLatlong[travel_id] = []
    }
    
    acLatlong[travel_id].push(new L.LatLng(lat, long)); 
}

function getTravelDistance(travel_id){
    var distance = getDistance(acLatlong[travel_id]);
    
    document.getElementById('travel-distance-'+travel_id).textContent = distance + ' km';

    return distance;
}


