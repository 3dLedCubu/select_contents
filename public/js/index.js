$('.icon').on('mouseup touchend', function () {
    const id = $(this).data('id');
    $.ajax({
        url: './select',
        type: 'POST',
        data: { 'id': id }
    })
        .fail(data => console.log('failed POST select'));

    $('.icon').each(function () {
        if ($(this).data('id') == id) {
            $(this).removeClass('unselected pressed').addClass('selected');
        } else {
            $(this).removeClass('selected pressed').addClass('unselected');
        }
    })
});

$('.icon').on('mousedown touchstart', function () {
    if ($(this).hasClass('unselected')) {
        $(this).removeClass('unselected').addClass('pressed');
    }
});

const getStatus = () => {
    $.getJSON('/status', function (data) {
        $.each(data, function (index) {
            target = $('#' + data[index].id + '_status')
            if (data[index].is_alive) {
                if (data[index].id == 'camera') {
                    $('#camera')[0].style.visibility = undefined;
                } else {
                    target.hide()
                }
            }
            else {
                if (data[index].id == 'camera') {
                    $('#camera')[0].style.visibility = 'hidden';
                } else {
                    target.show()
                }
            }
        });
    });
}

function preventDefault(e) {
    e.preventDefault();
}

function disableScroll() {
    document.body.addEventListener('touchmove', preventDefault, { passive: false });
}

$(document).ready(() => {
    disableScroll();
    setInterval(getStatus, 2000);
});
