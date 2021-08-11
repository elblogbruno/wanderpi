var buttonRecord = document.getElementById("record");
var buttonStop = document.getElementById("stop");
var statusBadgeContainer = document.getElementById("recording_status_container");
var statusBadge = document.getElementById("recording_status");
var downloadLink = document.getElementById("download_video");
var saveButton = document.getElementById("save_file");
var saveButtonModal = document.getElementById("save_request_button");
var cameraDropdown = document.querySelector('select#videoSource');
var socket = io();

var gps = document.getElementById("gps_text");
var map = L.map('map-container-google-1');
var file_name = "";
var global_travel_id = "";


var update_socket = false;
var lat = 0;
var long = 0;
var file_id = 0;



function init(travel_id) 
{
    saveButton.style.display = "none";
    downloadLink.style.display = "none";
    buttonStop.disabled = true;
    statusBadgeContainer.style.display = "none";

    global_travel_id = travel_id || "";
}

//when camera dropdown is changed, it will change the video source
cameraDropdown.onchange = function () {
    var videoSource = cameraDropdown.options[cameraDropdown.selectedIndex].value;
    var player = document.getElementById("video");
    
    player.src =  `/video_feed/${videoSource}/`;
}


function initializeCameraView(){
    var card = document.getElementById("video-card-body");
    
    var player = document.createElement("img");
    player.id = "video";
    player.className =  "camera-view-responsive card-img-top";
    player.src = '/video_feed/0/';

    card.appendChild(player);
}

function initializeDropdown() {
    
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
            obj = JSON.parse(xhr.responseText);
            var devices = obj.devices;
            for(var i = 0; i < devices.length; i ++){
                var device = devices[i];
                var option = document.createElement('option');
                if (i == 0) {
                    option.setAttribute('selected', 'selected');
                }
                option.value = device.index;
                option.text = device.deviceLabel || 'camera ' + (i + 1);
                document.querySelector('select#videoSource').appendChild(option);
            };
        }
    }

    xhr.open("POST", "/get_available_video_sources");
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();

    
}

window.addEventListener('DOMContentLoaded', (event) => {
    initializeDropdown();
    initializeCameraView();
});

buttonRecord.onclick = function () {
    setOnVideoStartUI();

    // XMLHttpRequest
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
        }
    }

    var url = "/record_status";

    console.log(file_id);

    if (file_id != 0) 
    {
        url = "/record_status?file_id="+file_id;
    } 

    xhr.open("POST",  url);
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({status: "true", travel_id: global_travel_id, is_image: false}));


    initializeMapAndLocator();
    update_socket = true;

    start_socket();
    // resetTimer();
    // startTimer();
};

function start_socket(){
    if (update_socket) {
        socket.emit('record_update', 'start');
    }
}

sending = setInterval(start_socket, 100);

socket.on("record_update", function (data) {
    console.log( "Data from python: " + data);
    if (data == "error"){
        update_socket = false;
    }
    statusBadge.textContent = data;
});

points = []
saveButtonModal.onclick = function () {
    //makes a request to save the video and when it is done, it will redirect to the home page where the video is saved
    // var xhr = new XMLHttpRequest();
    // xhr.onreadystatechange = function () {
    //     if (xhr.readyState == 4 && xhr.status == 200) {
    //         console.log(xhr.responseText);
    //         var response = JSON.parse(xhr.responseText);
    //         if (response.status_code == 200) {
    //             window.location.href = "/travel/"+global_travel_id;
    //         }
    //     }
    // }

    var name_input = document.getElementById("name_input");

    // var base_url = window.location.origin;
    // var url = new URL(base_url+"/save_file/"+ saveButton.value+'/');
  
    // url.searchParams.set('is_image', false);
    // url.searchParams.append('name', name_input.value);
    // url.searchParams.append('lat', lat);
    // url.searchParams.append('long', long);
    // url.searchParams.append('travel_id', global_travel_id);
    // url.searchParams.append('points', points);


      var data = {
        is_image : false,
        name : name_input.value,
        lat : lat,
        long : long,
        travel_id : global_travel_id,
        points : points
      };
    
      var js_data = JSON.stringify(data);
      
      console.log(js_data);

      $.ajax({
          url: "/save_file/"+ saveButton.value+'/',
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
                    window.location.href = "/travel/"+global_travel_id;
                }
            }
      });

    // xhr.open("POST", url.toString());
    // xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    // xhr.send();
};

function setOnVideoStartUI(){
    buttonRecord.disabled = true;
    buttonStop.disabled = false;
    saveButton.style.display = "none";
    downloadLink.style.display = "none";

    statusBadge.classList.remove('bg-success');
    statusBadge.classList.add('bg-danger');
    
    statusBadgeContainer.style.display = "block";
    statusBadge.innerHTML  = "Recording...";
}

function setOnVideoStopUI(){
    buttonRecord.disabled = false;
    buttonStop.disabled = true;
    
    duration = statusBadge.textContent;

    statusBadge.innerHTML  = "Stopped";

    statusBadge.classList.remove('bg-danger');
    statusBadge.classList.add('bg-success');

    map.stopLocate();

    setTimeout(function () {
        statusBadgeContainer.style.display = "none";
    }, 2000);

    var video_info_text = document.getElementById("video_info_text");
    video_info_text.textContent = "Video name: " + file_name + " Duration: " + duration;
}

buttonStop.onclick = function () {
    update_socket = false;
    // XMLHttpRequest
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
            obj = JSON.parse(xhr.responseText);

            if (obj.status_code == 200) {
                file_id = obj.file_id;
                var file_path = obj.file_path;
                file_name = obj.file_name;
                gps.innerHTML = file_name;

                saveButton.style.display = "inline";
                saveButton.value = file_id;
                downloadLink.style.display = "inline";
                downloadLink.onclick = function () {
                    window.location.href = "/uploads/"+ global_travel_id + "/" + file_id;
                }

                setOnVideoStopUI();
                
            }else{
                alert("Something went wrong");
            }
        }
    }
    

    xhr.open("POST", "/record_status");
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({status: "false", lat: lat, long: long, travel_id: global_travel_id, is_image: false}));
};

var saveWanderpiModal = document.getElementById('saveWanderpiModal')
saveWanderpiModal.addEventListener('show.bs.modal', function (event) {
  // Button that triggered the modal
  // var button = event.relatedTarget
  // Extract info from data-bs-* attributes
  var button = event.relatedTarget
  // Extract info from data-bs-* attributes
  global_travel_id = button.getAttribute('data-bs-whatever')

  var recipient = file_name;
  // If necessary, you could initiate an AJAX request here
  // and then do the updating in a callback.
  //
  // Update the modal's content.
  //var modalTitle = exampleModal.querySelector('.modal-title')
  var modalBodyInput = saveWanderpiModal.querySelector('.modal-body input')

  //modalTitle.textContent = 'New message to ' + recipient
  modalBodyInput.value = recipient
})


//function that inits leaflet map but shows text that says start recording to show map
function initializeMapAndLocator()
{ 
    var pathCoords = [];
    
    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);
    
    map.locate({setView: true, 
                 maxZoom: 15, 
                 watch:true,
                 enableHighAccuracy: true
               });
    
    function onLocationFound(e) 
    {
        //web request to add a point to database
        point = {
            lat: e.latlng.lat,
            long: e.latlng.lng,
        }
        points.push(point);

        pathCoords.push(e.latlng);

        var pathLine = L.polyline(pathCoords, {color: 'red'}).addTo(map);

        map.fitBounds(pathLine.getBounds());

        lat = e.latlng.lat;
        long = e.latlng.lng;
    }
    
    map.on('locationfound', onLocationFound);
    
}