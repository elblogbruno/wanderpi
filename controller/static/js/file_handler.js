var map;
var map_initiated = false;

function init_map()
{
    map = L.map('map-container-global');

    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 15,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);

    //map.setView([0,0], 2);
    
    map_initiated = true;
}

async  function shareVideo(id){
  console.log(id);
  const shareData = {
    title: 'MDN',
    text: 'Learn web development on MDN!',
    url: 'https://developer.mozilla.org',
  }

  await navigator.share(shareData)
}

var uploading_file = false, downloading_file = false;

var socket = io()

function disableButtons(){
  // document.getElementById('file-input').disabled = true;
  document.getElementById('download-button').disabled = true;
  document.getElementById('close-button').disabled = true;
  document.getElementById('process-upload-button').disabled = true;
}

function enableButtons(){
  // document.getElementById('file-input').disabled = false;
  document.getElementById('close-button').disabled = false;
  document.getElementById('download-button').disabled = false;
  document.getElementById('process-upload-button').disabled = false;
}

function startProcessingUploadFolder(travel_id)
{
    downloading_file = true;
    disableButtons()
    socket.emit('process_upload_folder_update', travel_id)
}

socket.on("process_upload_folder_update", function (data) {
  console.log( "Data from python: " + data);
  
  if (data == "200")
  {
      enableButtons()
  }else{
      document.getElementById("info-text-socket").textContent = data;
  }
});

document.getElementById("progress-bar").style.display = "none";
document.getElementById("bulk-edit-button").style.display = "none";

//https://stackoverflow.com/a/8758614/6683374
// $('#upload-button').on('click', function () {
//     let data = new FormData();
	
//     //for each file append it to the data object
//     var files = $('#file-input')[0].files;
//     //data.append('files[]', document.querySelector("#file-input").files[0]);
    

//     for (let i = 0; i < files.length; i++) {
//         data.append(i, files[i])
//     }
    
//     document.getElementById("progress-bar").style.display = "block";

//     $.ajax({
//       // Your server script to process the upload
//       url: '/upload/'+ $('#travel_id').val(),
//       type: 'POST',
  
      
//       // Form data
//       data: data,
  
//       // Tell jQuery not to process data or worry about content-type
//       // You *must* include these options!
//       cache: false,
//       contentType: false,
//       processData: false,
  
//       // Custom XMLHttpRequest
//       xhr: function () {
//         var myXhr = $.ajaxSettings.xhr();
//         if (myXhr.upload) {
//           // For handling the progress of the upload
//           myXhr.upload.addEventListener('progress', function (e) {
//             if (e.lengthComputable) {
//               $('progress').attr({
//                 value: e.loaded,
//                 max: e.total,
//               });
//             }
//           }, false);
//         }
//         return myXhr;
//       },
//       error: function (xhr, status, err) {
//         console.log(xhr.responseText);
//         console.log(status);
//         console.log(err);
//       },
//       complete : function(res) {
//         console.log(res.responseJSON.message);
//         if (res.responseJSON.error == 1){
//             document.getElementById("info-text").textContent = res.responseJSON.message;
//             document.getElementById("progress-bar").style.display = "none";
//             uploading_file = false;
//         }
//         if (res.responseJSON.error == 0){
//             uploading_file = false;
//             window.location.href = "/travel/"+ $('#travel_id').val();
//         }
//       }
//     });
//   });

var selectedCards = [];

function selectCard(file_id)
{
    var card = document.getElementById(file_id);
    var bulkEditButton = document.getElementById("bulk-edit-button");
    

    if (document.getElementById("card-selection-button-" + file_id).checked) 
    {
        console.log("card " + file_id + " selected");
        
        selectedCards.push(file_id);
        
        bulkEditButton.style.display = "inline";
        card.classList.add('selected-wanderpi');

    } else {
        console.log("card " + file_id + " deselected");
        
        removeItemOnce(selectedCards, file_id);
        card.classList.remove('selected-wanderpi');

        if (selectedCards.length == 0)
        {
            bulkEditButton.style.display = "none";
        }
        
    }

    console.log(selectedCards);
}

function removeItemOnce(arr, value) {
  var index = arr.indexOf(value);
  if (index > -1) {
    arr.splice(index, 1);
  }
  return arr;
}

function deleteSelectedFiles(travel_id){
    var url = "/bulk_delete_files";
    var js_data = JSON.stringify(selectedCards);

    $.ajax({
        url: url,
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
            console.log(data);
            if (data.error == 1){
                document.getElementById("info-text").textContent = data.message;
            }
            if (data.error == 0){
                window.location.href = "/travel/"+ travel_id;
            }
        }
    });
  
}

function editSelectedFiles(travel_id){
  var url = "/bulk_edit_files";

  var data = {
    files_to_edit: selectedCards,
    lat: map.getCenter().lat,
    long: map.getCenter().lng,
    //address: document.getElementById("new-location-input").value,
  };

  var js_data = JSON.stringify(data);

  $.ajax({
      url: url,
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
          console.log(data);
          if (data.error == 1){
              document.getElementById("info-text").textContent = data.message;
          }
          if (data.error == 0){
              window.location.href = "/travel/"+ travel_id;
          }
      }
  });

}

function getRandomLatLng(map) {
  var bounds = map.getBounds(),
    southWest = bounds.getSouthWest(),
    northEast = bounds.getNorthEast(),
    lngSpan = northEast.lng - southWest.lng,
    latSpan = northEast.lat - southWest.lat;

  return new L.LatLng(
      southWest.lat + latSpan * Math.random(),
      southWest.lng + lngSpan * Math.random());
}

var bulkEditModal = document.getElementById("bulkEditModal");

bulkEditModal.addEventListener('show.bs.modal', function (event) {
  if (!map_initiated) {
      init_map();
  }
  map.setView([0,0],15);
  var latl = getRandomLatLng(map);
  console.log(latl);
  map.setView([-10.8544921875, 49.82380908513249], 15);
  // map.locate({setView: true, 
  //   maxZoom: 15, 
  //   watch:true,
  //   enableHighAccuracy: true
  // });

  // function onLocationFound(e) 
  // {
      
  // }

  // map.on('locationfound', onLocationFound);

  map.on('click', function(e){
    var coord = e.latlng;
    var lat = coord.lat;
    var lng = coord.lng;
    console.log("You clicked the map at latitude: " + lat + " and longitude: " + lng);

    var radius = 2;
    console.log("The radius is: " + e.accuracy);
    lat = e.latitude;
    long = e.longitude;
    L.marker(e.latlng).addTo(map).bindPopup("You are within " + radius + " meters from this point").openPopup();
    L.circle(e.latlng, radius).addTo(map);

    map.setView(e.latlng, 15);

    //document.getElementById("new-location-input").value = lat + ", " + lng;

  });

});

//Download modal
function startDownloadingTravelVideo(travel_id)
{
    downloading_file = true;
    //disable button
    document.getElementById('download-button').disabled = true;
    document.getElementById('close-button').disabled = true;
    socket.emit('travel_download_update', travel_id)
}

socket.on("travel_download_update", function (data) {
    console.log( "Data from python: " + data);
    
    if (data == "200")
    {
        document.getElementById('close-button').disabled = false;
        document.getElementById('download-button').disabled = false;
    }else{
      document.getElementById("info-text-socket-travel-download").textContent = data;
    }
});


//search
function searchWanderpis(travel_id)
{
  var query = document.getElementById('search-input');

  if (query.value.length > 0) {
    var url = "/search/"+travel_id+"/"+query.value;

    window.location.href = url;
  }
}