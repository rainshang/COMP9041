(function () {
    'use strict';
    let outputDiv = document.getElementById('output');
    fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => response.json())
        .then(uJson => {
            fetch('https://jsonplaceholder.typicode.com/posts')
                .then(response => response.json())
                .then(pJson => {
                    uJson.forEach(uItem => {
                        let userDiv = document.createElement('div');
                        userDiv.className = 'user';
                        let userNameDiv = document.createElement('h2');
                        userNameDiv.innerText = uItem.name;
                        userDiv.appendChild(userNameDiv);
                        let companyCatchPhraseDiv = document.createElement('p');
                        companyCatchPhraseDiv.innerText = uItem.company.catchPhrase;
                        userDiv.appendChild(companyCatchPhraseDiv);
                        let postsDiv = document.createElement('ul');
                        postsDiv.className = 'posts';
                        pJson.forEach(pItem => {
                            if (pItem.userId == uItem.id) {
                                let postDiv = document.createElement('li');
                                postDiv.className = 'post';
                                postDiv.innerText = pItem.title;
                                postsDiv.appendChild(postDiv);
                            }
                        });
                        userDiv.appendChild(postsDiv);
                        outputDiv.appendChild(userDiv);
                    });
                });
        }
        );
}());
