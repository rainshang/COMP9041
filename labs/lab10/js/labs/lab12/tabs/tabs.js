(function () {
    'use strict';
    let navTabs = document.querySelector('[class="nav nav-tabs"]');
    let informationDiv = document.getElementById('information');
    fetch('planets.json')
        .then(response => response.json())
        .then(json => {
            for (let i = 0; i < navTabs.children.length; i++) {
                const navTab = navTabs.children[i];
                navTab.addEventListener('click', () => {
                    let id = navTab.children[0].id.split('-')[1];
                    const data = json[id - 1];

                    for (let j = 0; j < navTabs.children.length; j++) {
                        let aDiv = navTabs.children[j].children[0];
                        if (aDiv.id == 'tab-' + id) {
                            aDiv.className = 'nav-link active';
                        } else {
                            aDiv.className = 'nav-link';
                        }
                    }

                    informationDiv.innerHTML = '';
                    let h2 = document.createElement('h2');
                    h2.innerText = data.name;
                    informationDiv.appendChild(h2);
                    informationDiv.appendChild(document.createElement('hr'));
                    let p = document.createElement('p');
                    p.innerText = data.details;
                    informationDiv.appendChild(p);
                    let ul = document.createElement('ul');
                    informationDiv.appendChild(ul);
                    for (const [key, value] of Object.entries(data.summary)) {
                        let li = document.createElement('li');
                        ul.appendChild(li);
                        let b = document.createElement('b');
                        b.innerText = key + ':';
                        li.appendChild(b);
                        li.innerHTML += ' ' + value;
                    }
                });
            }
        });
}());
