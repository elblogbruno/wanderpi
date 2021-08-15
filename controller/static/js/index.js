$('#editTravelModal').on('show.bs.modal', function (event) {
    console.log("Initializing modal");
    var button = event.relatedTarget // Button that triggered the modal
    var travel_id = button.getAttribute('data-bs-travel')
    var name = button.getAttribute('data-bs-name')
    console.log(travel_id, name);
    // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
    // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
    var modal = $(this)
    modal.find('.modal-body input').val(name)
    

    document.getElementById('edit_travel_button').onclick = function () {
        editTravel(travel_id, name);
    };
});


function editTravel(travel_id, name){
    var data = {
        name : name,
    };
    
    var js_data = JSON.stringify(data);
      
    console.log(js_data);

    $.ajax({
        url: "/edit_travel/"+ travel_id,
        type: "POST",
        data: js_data,
        contentType: 'application/json',
        dataType : 'json',
        error: function(xhr, status, err) {
            console.log(xhr.responseText);
            console.log(status);
            console.log(err);
        },
        success: function(data) {

            if (data.status_code == 200) {
                window.location.href = "/";
            }
        },
    });

}

function AddTravel(){
    var name = document.getElementById("name_input").value;
    var destination = document.getElementById("destination_input").value;
    var startTime = document.getElementById("start_date_input").value;
    var endTime = document.getElementById("end_date_input").value;
    // var notes = document.getElementById("travel_notes").value;
    var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function () {
          if (xhr.readyState == 4 && xhr.status == 200) {
              console.log(xhr.responseText);

              //parse json response and see if status code is 200
              var response = JSON.parse(xhr.responseText);
              if (response.status_code == 200) {
                  window.location.href = "/";
              }
          }
      }

      var base_url = window.location.origin;
      var url = new URL(base_url+"/save_travel/");
    
      url.searchParams.append('name', name);
      url.searchParams.append('destination', destination);
      url.searchParams.append('start_date', startTime);
      url.searchParams.append('end_date', endTime);
      //   url.searchParams.append('notes', notes);
      

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
 

