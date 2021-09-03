var myCarousel = document.querySelector('#carouselExampleControls')
var carousel = new bootstrap.Carousel(myCarousel)

var per_page = 0;

var stop_id = "";
var next_num;
var map;
var map_initiated = false;

function init_map_for_file(lat, long)
{
    console.log("Initializing map for file");
    
    map = L.map('map-container-slide'); //file-map
    map.addControl(new L.Control.Fullscreen());

    googleStreets = L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);
    
    var latlng = new L.LatLng(lat, long);

    map.setView(latlng, randomNum(5, 9), {
        "animate": true,
        "pan": {
          "duration": 10
        }
    });

    map_initiated = true;
}

function setPagination(pagination_num)
{
    next_num = pagination_num;
}

function setPerPageNumber(per_page)
{
    this.per_page = per_page;
}

function setStopId(stop_id)
{
    this.stop_id = stop_id;
}

function setFileOnMap(lat, long)
{
    console.log(lat, long);
    
    if (!map_initiated){
        
        init_map_for_file(lat,long)
    }
    var latlng = new L.LatLng(lat, long);
    
    // map.setView(latlng, map.getZoom(), {
    //     "animate": true,
    //     "pan": {
    //       "duration": 10
    //     }
    // });
   
    map.flyTo(latlng, randomNum(5, 9), {
        animate: true,
        duration: 0.5
      });

    var marker = L.marker([lat,long]).addTo(map);

    
    // setTimeout(function() {
    //     map.invalidateSize();
    // }, 1);
}


function randomNum(min, max) {
	return Math.floor(Math.random() * (max - min)) + min; // You can remove the Math.floor if you don't want it to be an integer
}

carousel.ride = 'carousel';
carousel.interval = 2000;

myCarousel.addEventListener('slid.bs.carousel', function (event) {
    
    console.log("slide changed event");
    console.log(event)
    var slide = event.relatedTarget; // Button that triggered the modal
    var slide_index = slide.getAttribute('data-bs-index')
    var lat = slide.getAttribute('data-bs-file-lat')
    var long = slide.getAttribute('data-bs-file-long')
    
    setFileOnMap(lat,long);

    console.log(slide_index);

    if (slide_index == 1)
    {
        console.log(next_num);
        console.log("Arrived to end!");
        window.location.href = "/slide_view/"+stop_id+"/"+next_num;
    }
});