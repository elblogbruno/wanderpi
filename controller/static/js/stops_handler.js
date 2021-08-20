function add_stop(travel_id)
{
    var name = document.getElementById("name_input").value;
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

    xhr.open("POST", url.toString());
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
    
}

