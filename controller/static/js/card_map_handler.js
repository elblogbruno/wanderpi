// var pathCoords = [];

var acLatlong = {};

var map;
var map_initialized = false;

function initializeMap(travel_id)
{
    map = create_map(`map-container-google-${travel_id}`, true);
}

function initializeStopsList(sLat, sLong, sAddress, travel_id)
{
    if (!acLatlong.hasOwnProperty(travel_id)) 
    {
        acLatlong[travel_id] = []
    }

    acLatlong[travel_id].push(new L.LatLng(sLat,sLong))

    console.log("TRAVEL_ID:  " + travel_id + " LAT : "+ sLat + " LONG : " + sLong);

    var marker_html = `<a> ${sAddress} </a>`;
    var marker = L.marker([sLat, sLong]).bindPopup(marker_html).addTo(map);
}

//function that inits leaflet map but shows text that says start recording to show map
//https://gis.stackexchange.com/questions/53394/select-two-markers-draw-line-between-them-in-leaflet
function initializeMapAndLocator(travel_lat, travel_long, travel_id)
{ 
    function locate() {
      map.locate({setView: true, maxZoom: 16});
    }

    function onLocationFound(e) 
    {
        if (e.latlng.lat != 0)
          acLatlong[travel_id].push(e.latlng);

        var pathLine = L.polyline(acLatlong[travel_id], {color: 'red'}).addTo(map);

        sortByDistance(acLatlong[travel_id], e.latlng);

        console.log(acLatlong[travel_id]);
        
        map.fitBounds(pathLine.getBounds());

        setInterval(locate, 100000);
    }
    
    map.on('locationfound', onLocationFound);

    if (!acLatlong.hasOwnProperty(travel_id)) 
    {
        acLatlong[travel_id] = []
    }
    
    acLatlong[travel_id].push(new L.LatLng(travel_lat, travel_long))

    locate();
}
 

