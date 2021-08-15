var map;
var map_initiated = false;
var map_modified = false;

function init_map_for_editing()
{
    console.log("initialized map to edit");

    map = L.map('map-container-global');

    googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
            maxZoom: 15,
            subdomains:['mt0','mt1','mt2','mt3']
        }).addTo(map);
    
    map.setView([46.244553376495,-9.43842451847176], 2);
    map_initiated = true;
}


var selectedCards = [];

function addCard(file_id)
{
    selectedCards.push(file_id);
}

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
        }
    });
  
}

function editSelectedFiles(travel_id){
  var url = "/bulk_edit_files";

  var name_input = document.getElementById('name_input');
  var data = {
    files_to_edit: selectedCards,
    lat: map.getCenter().lat,
    long: map.getCenter().lng,
  };

  if (name_input) {
      if (map_modified) {
        data = {
            files_to_edit: selectedCards,
            lat: map.getCenter().lat,
            long: map.getCenter().lng,
            name: name_input.value,
        };
      }else{
            data = {
                files_to_edit: selectedCards,
                name: name_input.value,
            };
      }
  }

  var js_data = JSON.stringify(data);
  
  console.log(js_data);

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
              if (name_input) {
                  window.location.href = "/file/"   + selectedCards[0];
              } else {
                  window.location.href = "/travel/" + travel_id;
              }
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
var map1 = false;
bulkEditModal.addEventListener('show.bs.modal', function (event) {
  console.log(map1);
  if (map1 == false) {
      console.log("initialized map to edit");
      init_map_for_editing();
      map1 = true;
  }

  
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
    map_modified = true;
  });

});