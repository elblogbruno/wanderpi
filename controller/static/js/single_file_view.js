var list_of_points = [];
var map;

function init_map_for_file(file_id)
{
    console.log("Initializing map for file");

    map = create_map('file-map-'+file_id);
}

function showPosition(lat, long, address, file_id, show_map = true) {
    if (show_map) 
    {
        init_map_for_file(file_id);
        
        setTimeout(function() {
            map.invalidateSize();
            map.setView([lat,long], 13);
            var marker_html = `<a> ${address} </a>`;
            var marker = L.marker([lat, long]).bindPopup(marker_html).addTo(map);

        }, 1);
    }
}

function loadPoints(lat, long) {
    list_of_points.push(new L.LatLng(lat, long));
    
    var pathLine = L.polyline(list_of_points, {color: 'red'}).addTo(map);

    map.fitBounds(pathLine.getBounds());
}