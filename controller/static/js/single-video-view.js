
function showPosition(lat, long) {
    var gps = document.getElementById("gps_text");

    gps.innerHTML = lat + " " + long;
    var map = L.map('map-container-google-1');
    
    map.setView([lat,long], 13);

    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);
}