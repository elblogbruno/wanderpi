function add_stop(travel_id)
{
    var name = document.getElementById("name_input").value;
    var address_input = document.getElementById("address_input").value;

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);

            //parse json response and see if status code is 200
            var response = JSON.parse(xhr.responseText);
            if (response.status_code == 200) {
                window.location.href = "/travel/"+travel_id;
            }
        }
    }

    var base_url = window.location.origin;
    var url = new URL(base_url+"/add_stop/"+travel_id);
    
    url.searchParams.append('name', name);
    url.searchParams.append('address', address_input)

    xhr.open("POST", url.toString());
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
    
}



function editStop(stop_id, name, address)
{
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);

            //parse json response and see if status code is 200
            var response = JSON.parse(xhr.responseText);
            var travel_id = response.travel_id;

            if (response.status_code == 200) {
                window.location.href = "/travel/"+travel_id;
            }
        }
    }

    var base_url = window.location.origin;
    var url = new URL(base_url+"/edit_stop/"+stop_id);
    
    url.searchParams.append('name', name);
    url.searchParams.append('address', address);

    xhr.open("POST", url.toString());
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
    
}



var editStopModal = document.getElementById("editStopModal");

editStopModal.addEventListener('show.bs.modal', function (event) {
    console.log("Initializing modal");
    var button = event.relatedTarget // Button that triggered the modal
    var stop_id = button.getAttribute('data-bs-stop-id')
    var original_name = button.getAttribute('data-bs-name')
    var original_address = button.getAttribute('data-bs-address')
    
    console.log(stop_id, original_name, original_address);
    // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
    // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
    var modal = $(this)
    modal.find('#new_name_input').val(original_name)
    modal.find('#new_address_input').val(original_address)
    
    var new_name =  modal.find('#new_name_input').val();
    var new_address =  modal.find('#new_address_input').val();

    document.getElementById('edit_stop_button').onclick = function () {
        editStop(stop_id, new_name, new_address);
    };
});
