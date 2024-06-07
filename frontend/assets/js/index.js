$(document).ready(function (e) {
    $win = $(window);
    $navbar = $('#header');
    $toggle = $('.toggle-button');
    var width = $navbar.width();
    toggle_onclick($win, $navbar, width);

    // resize event
    $win.resize(function () {
        toggle_onclick($win, $navbar, width);
    });

    $toggle.click(function (e) {
        $navbar.toggleClass("toggle-left");
    })

});

function toggle_onclick($win, $navbar, width) {
    if ($win.width() <= 768) {
        $navbar.css({ left: `-${width}px` });
    } else {
        $navbar.css({ left: '0px' });
    }
}

var typed = new Typed('#typed', {
    strings: [
        'Cloud Engineer',
        'Cloud Architect',
        'DevOps Engineer',
        'Game Developer',
        'Music Producer'
    ],
    typeSpeed: 50,
    backSpeed: 50,
    loop: true
});

var typed_2 = new Typed('#typed_2', {
    strings: [
        'Cloud Engineer',
        'Cloud Architect',
        'DevOps Engineer',
        'Game Developer',
        'Music Producer'
    ],
    typeSpeed: 50,
    backSpeed: 50,
    loop: true
});

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();

        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

/*JavaScript Visitor Counter */
let counter = document.querySelectorAll(".counter-number");
async function visitCounter(){
    let response = await fetch(
        //"https://6b3yodlwsacqadv4mvip4r25pq0qcxes.lambda-url.us-east-1.on.aws/"
        "https://6qmxrx2gr5.execute-api.us-east-1.amazonaws.com/test"
    )
    let data = await response.json();
    for (var element of counter){
        element.innerHTML = "You are visitor "+ data + " :)"
    }
}
visitCounter();