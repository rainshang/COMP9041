(function () {
    'use strict';
    // write your code here
    let output = document.getElementById('output');
    output.innerHTML = new Date();
    window.setInterval(() => {
        output.innerHTML = new Date();
    }, 1000);
}());
