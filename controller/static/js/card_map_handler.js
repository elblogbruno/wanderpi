var pathCoords = [];
var map;
var map_initialized = false;

function initializeMap(travel_id)
{
  if (!map_initialized)
  {
    map = create_map(`map-container-google-${travel_id}`, true);
    map_initialized = true;
  } 
}

function initializeStopsList(sLat, sLong, sAddress){
    pathCoords.push(new L.LatLng(sLat,sLong))

    var marker_html = `<a> ${sAddress} </a>`;
    var marker = L.marker([sLat, sLong]).bindPopup(marker_html).addTo(map);
}

//function that inits leaflet map but shows text that says start recording to show map
//https://gis.stackexchange.com/questions/53394/select-two-markers-draw-line-between-them-in-leaflet
function initializeMapAndLocator(travel_lat, travel_long)
{ 
    function locate() {
      map.locate({setView: true, maxZoom: 16});
    }

    function onLocationFound(e) 
    {
        if (e.latlng.lat != 0)
          pathCoords.push(e.latlng);

        var pathLine = L.polyline(pathCoords, {color: 'red'}).addTo(map);

        console.log(pathCoords);

        sortByDistance(pathCoords, e.latlng);

        console.log(pathCoords);

        
        map.fitBounds(pathLine.getBounds());

        setInterval(locate, 100000);
    }
    
    map.on('locationfound', onLocationFound);

    pathCoords.push(new L.LatLng(travel_lat, travel_long))

    locate();
    // var xhr = new XMLHttpRequest();
    // xhr.onreadystatechange = function () {
    //     if (xhr.readyState == 4 && xhr.status == 200) {
    //         var response = JSON.parse(xhr.responseText);

    //         if (response.status_code == 200) {
    //           var lat = response.lat;
    //           var long = response.long;

    //           // console.log(lat, long);
          
    //           // call locate every 3 seconds... forever
    //           locate();
              
    //           pathCoords.push(new L.LatLng(lat, long));
    //         }
    //         else
    //         {
    //           console.log(response.status_code);
    //         }
    //     }

        
    // }

    // var base_url = window.location.origin;
    // var url = new URL(base_url+"/latlong/"+ travel_destination);
    // url.searchParams.append('travel_id', travel_id);

    // xhr.open("POST", url.toString());
    // xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    // xhr.send();
    
}
 

