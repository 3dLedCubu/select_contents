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
