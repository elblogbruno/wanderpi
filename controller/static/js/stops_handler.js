function add_stop(travel_id)
{
    var name = document.getElementById("name_input").value;
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);

            //parse json response and see if status code is 200
            var response = JSON.parse(xhr.responseText);
            if (response.status_code == 200) {
                window.location.href = "/travel/"+travel_id;
            }
        }
    }

    var base_url = window.location.origin;
    var url = new URL(base_url+"/add_stop/"+travel_id);
    
    url.searchParams.append('name', name);

    xhr.open("POST", url.toString());
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
    
}

//function that inits leaflet map but shows text that says start recording to show map
//https://gis.stackexchange.com/questions/53394/select-two-markers-draw-line-between-them-in-leaflet
function initializeMapAndLocator(travel_id, travel_destination)
{ 
    var pathCoords = [];
    var map = L.map(`map-container-google-${travel_id}`);
   
    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);
      
    function locate() {
        map.locate({setView: true, maxZoom: 16});
    }

    function onLocationFound(e) 
    {
        pathCoords.push(e.latlng);

        var pathLine = L.polyline(pathCoords, {color: 'red'}).addTo(map);

        map.fitBounds(pathLine.getBounds());

        setInterval(locate, 100000);
    }
    
    map.on('locationfound', onLocationFound);

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            var response = JSON.parse(xhr.responseText);

            if (response.status_code == 200) {
              var lat = response.lat;
              var long = response.long;

              // console.log(lat, long);
          
              // call locate every 3 seconds... forever
              locate();
              
              pathCoords.push(new L.LatLng(lat, long));
            }
            else
            {
              console.log(response.status_code);
            }
        }

        
    }

    var base_url = window.location.origin;
    var url = new URL(base_url+"/latlong/"+ travel_destination);
    url.searchParams.append('travel_id', travel_id);
    
    xhr.open("POST", url.toString());
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
    
}
    
