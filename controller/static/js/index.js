//when document has loaded initmodal
$(document).ready(function(){
    initModal();
});


function shareVideo(id){

    if (navigator.share) {
          navigator.share({
            title: 'WebShare API Demo',
            url: 'https://codepen.io/ayoisaiah/pen/YbNazJ'
          }).then(() => {
            console.log('Thanks for sharing!');
          })
          .catch(console.error);
        } else {
          // fallback
        }
}

function initModal(){
  var addTravelModal = document.getElementById('addTravelModal')

  addTravelModal.addEventListener('show.bs.modal', function (event) {
    var saveButtonModal = document.getElementById("save_request_button"); 
    saveButtonModal.onclick = function()
    {
      //get name, destionation, description, start time, end time, and duration from modal 
      var name = document.getElementById("name_input").value;
      var destination = document.getElementById("destination_input").value;
      var startTime = document.getElementById("start_date_input").value;
      var endTime = document.getElementById("end_date_input").value;

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

        xhr.open("POST", url.toString());
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xhr.send();
    };
  })

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

              console.log(lat, long);
          
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
    

//Get the button:
mybutton = document.getElementById("myBtn");

// When the user scrolls down 20px from the top of the document, show the button
window.onscroll = function() {scrollFunction()};

function scrollFunction() {
  if (document.body.scrollTop > 10 || document.documentElement.scrollTop > 10) {
    mybutton.style.display = "block";
  } else {
    mybutton.style.display = "none";
  }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.body.scrollTop = 0; // For Safari
  document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
}

