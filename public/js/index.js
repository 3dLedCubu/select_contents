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
        contents.forEach(function(c){
            var cls = ['selected', 'unselected'];
            if(c.selected){
                cls = cls.reverse();
            }
            var obj = $('#' + c.id);
            obj.removeClass(cls[0]);
            obj.addClass(cls[1]);
        });
    })
    .fail((data) => {
        alert('failed');
    })
}
