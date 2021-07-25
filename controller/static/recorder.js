var buttonRecord = document.getElementById("record");
var buttonStop = document.getElementById("stop");
var statusBadgeContainer = document.getElementById("recording_status_container");
var statusBadge = document.getElementById("recording_status");
var downloadLink = document.getElementById("download_video");
var saveButton = document.getElementById("save_video");


var gps = document.getElementById("gps_text");
var map = L.map('map-container-google-1');

saveButton.style.display = "none";
downloadLink.style.display = "none";
buttonStop.disabled = true;
statusBadgeContainer.style.display = "none";



buttonRecord.onclick = function () {
    // var url = window.location.href + "record_status";
    buttonRecord.disabled = true;
    buttonStop.disabled = false;

    // XMLHttpRequest
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
        }
    }
    
    statusBadge.classList.remove('bg-success');
    statusBadge.classList.add('bg-danger');
    
    statusBadgeContainer.style.display = "block";
    statusBadge.innerHTML  = "Recording...";

    xhr.open("POST", "/record_status");
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({status: "true"}));

    initializeMapAndLocator();
};

buttonStop.onclick = function () {
    buttonRecord.disabled = false;
    buttonStop.disabled = true;

    // XMLHttpRequest
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
            obj = JSON.parse(xhr.responseText);
            var video_id = obj.video_id;
            console.log(video_id);

            saveButton.style.display = "inline";
            downloadLink.style.display = "inline";
            downloadLink.onclick = function () {
                window.location.href = "/uploads/" + video_id;
            }
        }
    }
    statusBadge.innerHTML  = "Stopped";

    statusBadge.classList.remove('bg-danger');
    statusBadge.classList.add('bg-success');

    map.stopLocate();

    xhr.open("POST", "/record_status");
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({status: "false"}));
};



//function that inits leaflet map but shows text that says start recording to show map
function initializeMapAndLocator()
{ 
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
        console.log(e);
        var radius = e.accuracy / 2;
        L.marker(e.latlng).addTo(map).bindPopup("You are within " + radius + " meters from this point").openPopup();
        L.circle(e.latlng, radius).addTo(map);
    }
    
    map.on('locationfound', onLocationFound);
    
}
    
    

var pointList = [];

function showPosition(position) {
    var crd = position.coords;
    console.log('Your current position is:');
    console.log('Latitude : ' + crd.latitude);
    console.log('Longitude: ' + crd.longitude);
    console.log('More or less ' + crd.accuracy + ' meters.');

    gps.innerHTML = crd.latitude + " " + crd.longitude;

    // var mymap = L.map('map-container-google-1').setView([ position.coords.latitude, position.coords.longitude], 13);
    
    

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(mymap);

    realtime.on('update', function() {
        mymap.fitBounds(realtime.getBounds(), {maxZoom: 3});
        gps.innerHTML = realtime.latitude + " " + realtime.longitude;
    });

    // var pointA = new L.LatLng(position.coords.latitude, position.coords.longitude);
    
    // pointList.push(pointA);

    // var firstpolyline = new L.Polyline(pointList, {
    //     color: 'red',
    //     weight: 3,
    //     opacity: 0.5,
    //     smoothFactor: 1
    // });

    // firstpolyline.addTo(mymap);
}