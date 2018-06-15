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
    })
    .fail((data) => {
        alert('failed');
    })
}
