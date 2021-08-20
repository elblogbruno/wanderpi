var socket = io()

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