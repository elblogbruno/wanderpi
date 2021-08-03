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

//when document loads call function
window.onload = function() {
    var xhr= new XMLHttpRequest();
    xhr.open('GET', '/static/download_modal.html', true);
    xhr.onreadystatechange= function() {
        if (this.readyState!==4) return;
        if (this.status!==200) return;
        document.getElementById('dinamic-modal-body').innerHTML= this.responseText;
    };
    xhr.send();
}



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