const click_icon = id => {
    $.ajax({
        url:'./select',
        type:'POST',
        data:{ 'id' : id }
    })
    .done(data => {
        JSON.parse(data).select.forEach(c => {
            var cls = ['selected', 'unselected'];
            if(c.selected){
                cls = cls.reverse();
            }
            $('#' + c.id).removeClass(cls[0]).addClass(cls[1]);
        });

        // var sound = new Audio('Beep.mp3');
        // sound.play();    
    })
    .fail(data => alert('failed'));
}
