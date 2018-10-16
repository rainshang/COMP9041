(function () {
    'use strict';
    let outputDiv = document.getElementById('output');
    let loading = document.getElementById('loading');
    let done = [false, false, false, false, false,];
    let fetchImg = (i) => {
        fetch('https://picsum.photos/200/300/?random')
            .then(response => response.blob())
            .then(blob => {
                let imgPostDiv = document.createElement('div');
                imgPostDiv.className = 'img-post';
                let img = document.createElement('img');
                img.src = URL.createObjectURL(blob);
                imgPostDiv.appendChild(img);
                let p = document.createElement('p');
                p.innerText = 'Fetched at ' + new Date().toTimeString();
                imgPostDiv.appendChild(p);
                outputDiv.appendChild(imgPostDiv);

                done[i] = true;
                let allDone = true;
                done.forEach(element => allDone &= element);
                if (allDone) {
                    loading.style.display = 'none';
                }
            });
    }

    document.getElementById('more')
        .addEventListener('click', () => {
            outputDiv.innerHTML = '';
            outputDiv.append(loading);
            loading.style.display = 'block';
            for (let i = 0; i < 5; i++) {
                fetchImg(i);
            }
        });

}());
