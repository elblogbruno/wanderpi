

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
    document.getElementById("progress-bar").style.display = "inline";
    socket.emit('process_upload_folder_update', travel_id)
}

socket.on("process_upload_folder_update", function (data) {
  console.log( "Data from python: " + data);
  
  if (data == "200")
  {
      document.getElementById("progress-bar").style.display = "none";
      enableButtons()
  }else{
      document.getElementById("info-text-socket").textContent = data;
  }
});

document.getElementById("progress-bar").style.display = "none";
document.getElementById("bulk-edit-button").style.display = "none";




//search
function searchWanderpis(travel_id)
{
  var query = document.getElementById('search-input');

  if (query.value.length > 0) {
    var url = "/search/"+travel_id+"/"+query.value;

    window.location.href = url;
  }
}