(function () {
    'use strict';
    // code here
    let player = document.getElementById('player');
    let mode = 0;// 0: walk; 1: sprint
    let step = () => 5 * (mode ? 5 : 1);
    let getMove = (base, value) => (base + value) + 'px';
    let is60fps = true;// true: 60fps; false: 30fps

    let fire = document.createElement('div');
    fire.style.cssText = "width: 60px;height: 52px;background-image: url('imgs/fireball.png');background-size: cover;position: absolute;display: none;";
    document.body.appendChild(fire);

    document.addEventListener('keydown', (event) => {
        switch (event.key) {
            case 'ArrowLeft':
                player.style.left = getMove(player.offsetLeft, -step());
                break;
            case 'ArrowUp':
                player.style.top = getMove(player.offsetTop, -step());
                break;
            case 'ArrowRight':
                player.style.left = getMove(player.offsetLeft, step());
                break;
            case 'ArrowDown':
                player.style.top = getMove(player.offsetTop, step());
                break;
            case 'Z':
            case 'z':
                mode = !mode;
                break;
            case 'X':
            case 'x':
                if (fire.style.display == 'none') {
                    let playerRight = player.offsetLeft + player.offsetWidth;
                    fire.style.left = playerRight + 'px';
                    fire.style.top = player.offsetTop + 30 + 'px';
                    fire.style.display = 'block';
                    let interval = window.setInterval(() => {
                        fire.style.left = (fire.offsetLeft + (is60fps ? 10 : 20)) + 'px';
                        if (fire.offsetLeft > window.innerWidth) {
                            window.clearInterval(interval);
                            fire.style.display = 'none';
                        }
                    }, 1000 / (is60fps ? 60 : 30));
                }
                break;
            case 'S':
            case 's':
                is60fps = !is60fps;
            default:
                break;
        }
    });
}());
