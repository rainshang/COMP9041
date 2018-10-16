(function () {
    let worker = new Worker('worker.js');
    let img = document.getElementById('cat');
    if (window.Worker) {
        worker.onmessage = e => {
            img.src = e.data;
        }
        window.setInterval(() => {
            worker.postMessage('Go to fetch my cat!');
        }, 5000);
        worker.postMessage('Go to fetch my cat!');
    }
}());
