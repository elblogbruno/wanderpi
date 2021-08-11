var list_of_points = [];
var map;
var map_initiated = false;

function init_map_for_file()
{
    console.log("Initializing map for file");
    map = L.map('file-map'); //file-map

    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);

    map_initiated = true;
}

function showPosition(lat, long, address) {
    if (map_initiated == false) {
        init_map_for_file();
    }

    var latitude_text = document.getElementById("latitude_text");

    latitude_text.textContent = "Latitude: " + lat;
    
    var longitude_text = document.getElementById("longitude_text");
    longitude_text.textContent =  "Longitude: " + long;

    var address_text = document.getElementById("address_text");

    address_text.textContent = "Address: " + address;

    map.setView([lat,long], 13);

    //add marker
    var marker = L.marker([lat, long]).addTo(map);
}

function loadPoints(lat, long) {
    if (map_initiated == false) {
        
        init_map_for_file();
    }

    list_of_points.push(new L.LatLng(lat, long));
    
    var pathLine = L.polyline(list_of_points, {color: 'red'}).addTo(map);

    map.fitBounds(pathLine.getBounds());
}