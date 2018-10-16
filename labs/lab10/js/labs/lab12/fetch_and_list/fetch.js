(function () {
    'use strict';
    let outputDiv = document.getElementById('output');
    fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => response.json())
        .then(json => json.forEach(element => {
            let userDiv = document.createElement('div');
            userDiv.className = 'user';
            let userNameDiv = document.createElement('h2');
            userNameDiv.innerText = element.name;
            userDiv.appendChild(userNameDiv);
            let companyCatchPhraseDiv = document.createElement('p');
            companyCatchPhraseDiv.innerText = element.company.catchPhrase;
            userDiv.appendChild(companyCatchPhraseDiv);
            outputDiv.appendChild(userDiv);
        }));
}());
