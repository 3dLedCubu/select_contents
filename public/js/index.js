const click_icon = id => {
    $.ajax({
        url:'./select',
        type:'POST',
        data:{ 'id' : id }
    })

    .fail(data => alert('failed'));

    $('.icon').each((index, element) => {
        console.info(element);
        var cls = ['selected', 'unselected'];
        if(element.id == id){
            cls = cls.reverse();
        }
        $('#' + element.id).removeClass(cls[0]).addClass(cls[1]);
    })
}

const getStatus = () =>{
    $.getJSON('/status', function(data) {
        $.each(data, function(index) {
            target = $('#' + data[index].id + '_status')
            if (data[index].enable){
                // hide
                target.hide()
            }
            else{
                target.show()
            }
        });
    });
}

$(document).ready(() => {
    setInterval(getStatus, 1000); 
});
