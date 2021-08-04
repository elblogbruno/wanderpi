var buttonRecord = document.getElementById("record");
var buttonStop = document.getElementById("stop");
var statusBadgeContainer = document.getElementById("recording_status_container");
var statusBadge = document.getElementById("recording_status");
var downloadLink = document.getElementById("download_video");
var saveButton = document.getElementById("save_video");
var saveButtonModal = document.getElementById("save_request_button");
var cameraDropdown = document.querySelector('select#videoSource');

var gps = document.getElementById("gps_text");
var map = L.map('map-container-google-1');
var video_name = "";
var travel_id = "";

saveButton.style.display = "none";
downloadLink.style.display = "none";
buttonStop.disabled = true;
statusBadgeContainer.style.display = "none";

var lat = 0;
var long = 0;
var video_id = 0;

//when camera dropdwon is changed, it will change the video source
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

var stopTimerControl = false;
var counter = 0;
var timer = counter, minutes, seconds;

function resetTimer(){
    stopTimerControl = false;
    counter = 0;
}
function stopTimer(){
    stopTimerControl = true;
    counter = 0;
}
function startTimer()  {  
    
    setInterval(function () {
        if (!stopTimerControl) {
            minutes = parseInt(timer / 60, 10)
            seconds = parseInt(timer % 60, 10);

            minutes = minutes < 10 ? "0" + minutes : minutes;
            seconds = seconds < 10 ? "0" + seconds : seconds;

            statusBadge.textContent = minutes + ":" + seconds;

            timer++;
        }
    }, 1000);
}

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

    console.log(video_id);

    if (video_id != 0) 
    {
        url = "/record_status?video_id="+video_id;
    } 

    xhr.open("POST",  url);
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({status: "true"}));


    initializeMapAndLocator();
    
    resetTimer();
    startTimer();
};

saveButtonModal.onclick = function () {
    //makes a request to save the video and when it is done, it will redirect to the home page where the video is saved
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
            var response = JSON.parse(xhr.responseText);
            if (response.status_code == 200) {
                window.location.href = "/travel/"+travel_id;
            }
        }
    }

    var name_input = document.getElementById("name_input");

    var base_url = window.location.origin;
    var url = new URL(base_url+"/save_video/"+ saveButton.value+'/');
  
    url.searchParams.append('name', name_input.value);
    url.searchParams.append('lat', lat);
    url.searchParams.append('long', long);
    url.searchParams.append('travel_id', travel_id);

    xhr.open("POST", url.toString());
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
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

    statusBadge.innerHTML  = "Stopped";

    statusBadge.classList.remove('bg-danger');
    statusBadge.classList.add('bg-success');

    map.stopLocate();

    setTimeout(function () {
        statusBadgeContainer.style.display = "none";
    }, 2000);

    var video_info_text = document.getElementById("video_info_text");
    video_info_text.textContent = "Video name: " + video_name + " Duration: " + minutes + ":" + seconds;
}

buttonStop.onclick = function () {
    stopTimer();
    // XMLHttpRequest
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
            obj = JSON.parse(xhr.responseText);

            if (obj.status_code == 200) {
                video_id = obj.video_id;
                
                video_name = obj.video_name;
                gps.innerHTML = video_name;

                saveButton.style.display = "inline";
                saveButton.value = video_id;
                downloadLink.style.display = "inline";
                downloadLink.onclick = function () {
                    window.location.href = "/uploads/" + video_id + '.mp4';
                }

                setOnVideoStopUI();
                
            }else{
                alert("Something went wrong");
            }
        }
    }
    

    xhr.open("POST", "/record_status");
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({status: "false", lat: lat, long: long}));
};

var saveWanderpiModal = document.getElementById('saveWanderpiModal')
saveWanderpiModal.addEventListener('show.bs.modal', function (event) {
  // Button that triggered the modal
  // var button = event.relatedTarget
  // Extract info from data-bs-* attributes
  var button = event.relatedTarget
  // Extract info from data-bs-* attributes
  travel_id = button.getAttribute('data-bs-whatever')

  var recipient = video_name;
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
        pathCoords.push(e.latlng);

        var pathLine = L.polyline(pathCoords, {color: 'red'}).addTo(map);

        map.fitBounds(pathLine.getBounds());
    }
    
    map.on('locationfound', onLocationFound);
    
}