
async  function shareVideo(id){
  console.log(id);
  const shareData = {
    title: 'MDN',
    text: 'Learn web development on MDN!',
    url: 'https://developer.mozilla.org',
  }

  await navigator.share(shareData)
}
var socket = io()

var uploading_file = false, downloading_file = false;

function disableButtons(){
  // document.getElementById('file-input').disabled = true;
  document.getElementById('download-button').disabled = true;
  document.getElementById('close-button').disabled = true;
  document.getElementById('process-upload-button').disabled = true;
  document.getElementById("progress-bar").style.display = "inline";
  if (document.getElementById("myDropzone"))
    document.getElementById("myDropzone").style.display = "none";
}

function enableButtons(){
  // document.getElementById('file-input').disabled = false;
  document.getElementById('close-button').disabled = false;
  document.getElementById('download-button').disabled = false;
  document.getElementById('process-upload-button').disabled = false;
  document.getElementById("progress-bar").style.display = "none";
  if (document.getElementById("myDropzone"))
    document.getElementById("myDropzone").style.display = "block";
}

function startRecreatingThumbnails(stop_id){
  disableButtons()
  socket.emit('process_recreate_thumbnails', stop_id)
}

function startProcessingUploadFolderForStop(stop_id)
{
    downloading_file = true;
    disableButtons()
    socket.emit('process_upload_folder_update', stop_id)
}

function startProcessingUploadFolderForTravel(travel_id)
{
    downloading_file = true;
    disableButtons()
    socket.emit('process_travel_upload_folder_update', travel_id)
}

function get_upload_status()
{
    socket.emit('get_upload_status', 'data')
}

function ask_for_update(){
  socket.emit('process_travel_upload_folder_update', 'ok')
  setInterval(function(){ 
    ask_for_update();
  }, 5000);
}

socket.on('process_upload_folder_update_counter', function(data){
    document.getElementById("info-text-socket-counter").innerHTML = data;
})

socket.on("process_upload_folder_update", function (data) {
  console.log( "Data from python: " + data);
  
  if (data == "200")
  {
      enableButtons()
  }else{
      document.getElementById("info-text-socket").textContent = data;
  }
});

socket.on("process_travel_upload_folder_update", function (data) {
  console.log( "Data from python: " + data);
  
  if (data == "200")
  {
      enableButtons()
  }else{
      document.getElementById("info-text-socket").textContent = data;
  }
});

socket.on("get_upload_status", function (data) {
  console.log( "Data from python: " + data);
  
  if (data == 'False')
  {
      document.getElementById("progress-bar").style.display = "none";
      enableButtons()
  }else{
      document.getElementById("info-text-socket").textContent = data;
      // socket.emit('process_travel_upload_folder_update', 'ok')
      ask_for_update()
  }
});

$('#uploadFileModal').on('show.bs.modal', function (event) {
  get_upload_status();
})

document.getElementById("progress-bar").style.display = "none";

if (document.getElementById("bulk-edit-button"))
  document.getElementById("bulk-edit-button").style.display = "none";


//search
function searchWanderpis(stop_id)
{
  var query = document.getElementById('search-input');

  if (query.value.length > 0) {
    var url = "/stop/"+stop_id+"/?query="+query.value;

    window.location.href = url;
  }
}