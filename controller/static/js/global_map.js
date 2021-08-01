
var list_of_points = [];
var map;
var map_initiated = false;
var markers;
var gps = document.getElementById("gps_text");

function init_map()
{
    map = L.map('map-container-global');

    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);

    markers = new L.MarkerClusterGroup({ 
        spiderfyOnMaxZoom: false, 
        showCoverageOnHover: false, 
        zoomToBoundsOnClick: false 
    });
    

    map_initiated = true;
}

//function that checks if a point is already on the map
function is_point_on_map(lat, long) {
    for (var i = 0; i < list_of_points.length; i++) {
        console.log(lat,list_of_points[i].lat, long, list_of_points[i].lng);
        if (list_of_points[i].lat == lat && list_of_points[i].lng == long) {
            return true;
        }
    }
    return false;
}


function plot_map(lat, long, name, thumbnail_path, id) {
    if (!map_initiated) {
        init_map();
    }

    map.setView([lat,long], 13);

    var a = "/static/thumbnails/"+ thumbnail_path;
    
    var marker_html = `<a href="${id}"> ${name} </a> <img src='${a}' height='150px' width='150px'/>`;

    var does_exist = is_point_on_map(lat, long);

    if(does_exist)
    {
        marker =  L.marker([lat, long]).bindPopup(marker_html).openPopup();

        markers.on('clusterclick', function (a) {
			a.layer.zoomToBounds();
		});

        markers.addLayer(marker).addTo(map);
    }else
    {
        var marker =  L.marker([lat, long]).addTo(map).bindPopup(marker_html).openPopup();
    }
    
    list_of_points.push(new L.LatLng(lat, long));
}