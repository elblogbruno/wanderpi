$('#addNoteModal').on('show.bs.modal', function (event) {
    var button = event.relatedTarget // Button that triggered the modal
    var day = button.getAttribute('data-bs-day') // Extract info from data-* attributes
    var original_note_content = button.getAttribute('data-bs-content')
    var travel_id = button.getAttribute('data-bs-travel')
    var note_id = button.getAttribute('data-bs-note-id')
    get_costs(note_id)
    // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
    // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
    var modal = $(this)
    modal.find('.modal-title').text('Note at ' + day)
    modal.find('.modal-body textarea').val(original_note_content)
    

    document.getElementById('save_request_button').onclick = function () {
        var note_content = document.getElementById("note_content").value;
        console.log(note_content);
        var cost_container  = document.querySelector(".repeatable");
        costs = [];
        //field-group-{?}
        for (let index = 0; index < cost_container.children.length; index++) {
            var input_name = document.getElementById('input-price-name-new'+index) //input-price-name-new0
            var name = input_name.value;
            var price = document.getElementById('input-price-value-new'+index).value;
            var id = document.getElementById('input-price-id-new'+index).value;
            console.log(id);
            
            if (id){
                dic = {
                    name: name,
                    value: price,
                    money_id: id,
                }
                
            }   else{
                dic = {
                    name: name,
                    value: price,
                }
            }
            console.log(dic)

            costs.push(dic);
        }
        addNote(travel_id, note_content, costs, note_id);
    };
  })



function addNote(travel_id, note_content, costs, note_id){
    var data = {
        note_content : note_content,
        costs : costs,
        note_id : note_id,
    };
    
    var js_data = JSON.stringify(data);
      
    console.log(js_data);

    $.ajax({
        url: "/add_note_to_travel/"+ travel_id,
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

            if (data.status_code == 200) {
                window.location.href = "/travel_calendar/"+travel_id;
            }
        },
    });

}

$(".input-money .repeatable").repeatable({
    addTrigger: ".add",
    deleteTrigger: ".delete",
    template: '#input-money',
    itemContainer: ".field-group",
});

var next = 0;
function clone(name, value, id){
    let button = document.querySelector(".add");
    button.click();
    next = next + 1;
    nextBefore = next-1;

    // $('#input-money-field-'+nextBefore).first().clone().prop('id','input-money-field-'+next).appendTo('#fields');
    
    // $("#add-more-"+nextBefore).attr('id', 'add-more-'+next)
    // $("#input-price-name-"+nextBefore).attr('id', 'input-price-name-'+next)
    $("#input-price-name-new"+nextBefore).val(name)

    // $("#input-price-value-"+nextBefore).attr('id', 'input-price-value-'+next)
    $("#input-price-value-new"+nextBefore).val(value)
    
    // $("#input-price-id-"+nextBefore).attr('id', 'input-price-id-'+next)
    $("#input-price-id-new"+nextBefore).val(id)
    // $(".input-money .repeatable").repeatable.addOne();
    
    
    console.log("added new clone: " + next);
}

function remove(id){
    console.log(id);
    fields = document.getElementById("fields")
    console.log(fields.children.length);
    console.log(fields.children);
    if(fields.children.length > 1){
        for (let index = 0; index < fields.children.length; index++) {
            const element = fields.children[index];
            if (element.id = id){
                fields.removeChild(fields.children[index]);
                break;
            }
        }
    }
}

function get_costs(note_id){
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            console.log(xhr.responseText);
            obj = JSON.parse(xhr.responseText);
            console.log(obj)
            if (obj.status_code == 200) {
                var note_input_prices = obj.price_input
                instantiateCosts(note_input_prices);
            }else{
                alert("Something went wrong");
            }
        }
    }
    

    xhr.open("POST", "/get_note_info/"+note_id);
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send();
}

function instantiateCosts(note_input_prices){
    console.log(note_input_prices);
    
    if (note_input_prices.length >= 1){
        console.log("We need to add existing costs");
        for (let index = 0; index < note_input_prices.length; index++) {
            const element = note_input_prices[index];
            var name = element.name;
            var value = element.value;
            var id = element.id;
            clone(name, value,id);
        }
    }else{
        console.log("Adding no costs")
    }
}