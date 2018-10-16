// your web worker goes here.
onmessage = e => {
    fetch('https://api.thecatapi.com/v1/images/search?&mime_types=image/gif')
        .then(res => res.json())
        .then(json => {
            postMessage(json[0].url)
            // fetch(json[0].url)
            //     .then(res => res.blob())
            //     .then(bolb => postMessage(URL.createObjectURL(bolb)));
        });
}