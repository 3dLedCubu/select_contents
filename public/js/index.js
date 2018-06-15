function click_icon(id)
{
    $.ajax({
        url:'./select',
        type:'POST',
        data:{
            'id' : id
        }
    })
    .done((data) => {
        $(id).css('selected');
    })
    .fail((data) => {
        alert('failed');
    })
}
