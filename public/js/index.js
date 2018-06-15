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
        var contents = JSON.parse(data).select;
        for(var i = 0; i < contents.length; ++i) {
            var c = contents[i];
            document.getElementById(c.id).className = c.selected ? 'selected' : 'unselected';
        }
    })
    .fail((data) => {
        alert('failed');
    })
}
