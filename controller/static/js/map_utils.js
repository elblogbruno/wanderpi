//having a list of coordenates, calculates total distance
function calculateDistance(list_of_points) 
{
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

var singlePointsList = [];
var acLatlong = {};

function is_point_on_map(lat, long, travel_id) 
{
    for (var i = 0; i < acLatlong[travel_id].length; i++) {
        if (acLatlong[travel_id][i].lat == lat && acLatlong[travel_id][i].lng == long) {
            return true;
        }
    }
    return false;
}

function loadDistanceListFromWanderpis(lat, long, travel_id)
{
    // if keys are not set, then we are starting a new map
    if (!acLatlong.hasOwnProperty(travel_id)) 
    {
        acLatlong[travel_id] = []
    }
    
    if (!is_point_on_map(lat, long, travel_id) && (lat != 0 && long != 0))
        acLatlong[travel_id].push(new L.LatLng(lat, long)); 
}

function loadDistanceListFromPoints(lat, long)
{
    singlePointsList.push(new L.LatLng(lat, long)); 
}

function getDistance(){
    var distance = calculateDistance(singlePointsList);
    
    document.getElementById('distance-result').textContent = distance + ' km';

    return distance;
}

function getDistanceByList(list_points)
{
    var distance = calculateDistance(list_points);

    return distance;
}

function getDistanceByTravelId(travel_id){
    console.log(acLatlong);

    var distance = calculateDistance(acLatlong[travel_id]);
    
    document.getElementById('distance-result-'+travel_id).textContent = distance + ' km';

    return distance;
}


const distance = (coor1, coor2) => {
//    console.log(coor1, coor2);
   var d = getDistanceBetweenPoints(coor1.lat, coor1.lng, coor2.lat, coor2.lng);
//    console.log(d);
   return d;
};

const sortByDistance = (coordinates, point) => {
   const sorter = (a, b) => distance(a, point) - distance(b, point);
   coordinates.sort(sorter);
};


function create_map(map_id, add_fullscreen)
{
    console.log("Initializing map with id: " + map_id);
    map = L.map(map_id); //file-map

    googleStreets = L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);
    
    if (add_fullscreen)
    {
        map.addControl(new L.Control.Fullscreen());
    }

    return map;
}