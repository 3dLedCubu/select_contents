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
            var obj = $('#' + c.id);
            if(c.selected){
                obj.removeClass('unselected');
                obj.addClass('selected');
            }else{
                obj.removeClass('selected');
                obj.addClass('unselected');
            }
        }
    })
    .fail((data) => {
        alert('failed');
    })
}
