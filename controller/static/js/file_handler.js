

var button = document.getElementById('download_all_wanderpis');

// button.onclick = function() {
//     var url = 'http://localhost:8080/api/download_all_wanderpis';
//     var xhr = new XMLHttpRequest();
//     xhr.open('GET', url, true);
//     xhr.responseType = 'blob';
//     xhr.onload = function() {
//         if (xhr.status === 200) {
//             var blob = xhr.response;
//             saveAs(blob, 'wanderpis.zip');
//         }
//     };
//     xhr.send();
// }
$("#main").click(function() {
    $("#mini-fab").toggleClass('d-none');
});
  
$(document).ready(function(){
    $('[data-bs-toggle="tooltip"]').tooltip();  
});

var socket = io()
  
function send(){
    socket.emit('update', "Started Uploading")
}

sending = setInterval(send, 1000);

socket.on("update", function (data) {
    console.log( "Data from python: " + data);
    document.getElementById("info-text-socket").textContent = data;
});

$('#file-input').on('change', function () {
    document.getElementById("info-text").textContent = "";
    var file = this.files;
    
    var total_size = 0;
    for (var i = 0; i < file.length; i++) {
        total_size += file[i].size;
    }
    var size = total_size / 1024 / 1024;

    if (total_size > 200 * 1024 * 1024) {
      alert('Max upload size is 100 mb');
      this.value = null;
    }
    
    
    // Also see .name, .type
});

document.getElementById("progress-bar").style.display = "none";

//https://stackoverflow.com/a/8758614/6683374
$('#upload-button').on('click', function () {
    let data = new FormData();
	
    //for each file append it to the data object
    var files = $('#file-input')[0].files;
    //data.append('files[]', document.querySelector("#file-input").files[0]);
    

    for (let i = 0; i < files.length; i++) {
        data.append(i, files[i])
    }
    
    document.getElementById("progress-bar").style.display = "block";

    $.ajax({
      // Your server script to process the upload
      url: '/upload/'+ $('#travel_id').val(),
      type: 'POST',
  
      
      // Form data
      data: data,
  
      // Tell jQuery not to process data or worry about content-type
      // You *must* include these options!
      cache: false,
      contentType: false,
      processData: false,
  
      // Custom XMLHttpRequest
      xhr: function () {
        var myXhr = $.ajaxSettings.xhr();
        if (myXhr.upload) {
          // For handling the progress of the upload
          myXhr.upload.addEventListener('progress', function (e) {
            if (e.lengthComputable) {
              $('progress').attr({
                value: e.loaded,
                max: e.total,
              });
            }
          }, false);
        }
        return myXhr;
      },
      error: function (xhr, status, err) {
        console.log(xhr.responseText);
        console.log(status);
        console.log(err);
      },
      complete : function(res) {
        console.log(res.responseJSON.message);
        if (res.responseJSON.error == 1){
            document.getElementById("info-text").textContent = res.responseJSON.message;
            document.getElementById("progress-bar").style.display = "none";
        }
        if (res.responseJSON.error == 0){
            window.location.href = "/travel/"+ $('#travel_id').val();
        }
      }
    });
  });

//when document loads call function
// window.onload = function() {
//     loadModal();
// }

// function loadModal()
// {
//     var xhr= new XMLHttpRequest();
//     xhr.open('GET', '/static/html-templates/download_modal.html', true);
//     xhr.onreadystatechange= function() {
//         if (this.readyState!==4) return;
//         if (this.status!==200) return;
//         document.getElementById('dinamic-modal-body').innerHTML= this.responseText;
//     };
//     xhr.send();
// }


// button.onclick = function() {
//     var xhr= new XMLHttpRequest();
//     xhr.open('GET', '/static/download_modal.html', true);
//     xhr.onreadystatechange= function() {
//         if (this.readyState!==4) return;
//         if (this.status!==200) return;
//         document.getElementById('dinamic-modal-body').innerHTML= this.responseText;
//     };
//     xhr.send();
// }