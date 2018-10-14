// importing named exports we use brackets
import { createPostTile, uploadImage } from './helpers.js';

// when importing 'default' exports, use below syntax
import API from './api.js';

const api = new API();

// we can use this single api request multiple times
// const feed = api.getFeed();

// feed
//     .then(posts => {
//         posts.reduce((parent, post) => {

//             parent.appendChild(createPostTile(post));

//             return parent;

//         }, document.getElementById('large-feed'))
//     });

// // Potential example to upload an image
// const input = document.querySelector('input[type="file"]');

// input.addEventListener('change', uploadImage);

// get nav items
let usernameDiv = document.getElementById('username');
let loginDiv = document.getElementById('login');
let registerDiv = document.getElementById('register');

let loginDialog = document.querySelector('[role="login"]');
let registerDialog = document.querySelector('[role="register"]');

loginDiv.onclick = () => {
    loginDialog.style.display = 'block';

};
document.getElementById('login-dialog-close').onclick = () => {
    loginDialog.style.display = 'none';
};
document.getElementById('login-dialog-btn').onclick = () => {
    api.login(
        document.forms['login-form']['username'].value,
        document.forms['login-form']['password'].value)
        .then(result => {
            if (result.token) {
                api.setToken(result.token);
                api.getUser()
                    .then(result => {
                        setCookie('token', result.token, 30);
                        setCookie('userInfo', JSON.stringify(result), 30);
                        refreshNav();
                        loginDialog.style.display = 'none';
                    })
            }
        })
};

registerDiv.onclick = () => {
    registerDialog.style.display = 'block';

};
document.getElementById('register-dialog-close').onclick = () => {
    registerDialog.style.display = 'none';
};
document.getElementById('register-dialog-btn').onclick = () => {
    api.register(
        document.forms['register-form']['username'].value,
        document.forms['register-form']['password'].value,
        document.forms['register-form']['email'].value,
        document.forms['register-form']['name'].value)
        .then(result => {
            if (result.token) {
                api.setToken(result.token);
                api.getUser()
                    .then(result => {
                        setCookie('token', result.token, 30);
                        setCookie('userInfo', JSON.stringify(result), 30);
                        refreshNav();
                        registerDialog.style.display = 'none';
                    })
            }
        })
};

// setCookie('token', '', 0);
// setCookie('userInfo', '', 0);

refreshNav();

function refreshNav() {
    if (getCookie('token')) {
        let userInfo = JSON.parse(getCookie('userInfo'));
        usernameDiv.innerText = userInfo.name;
        usernameDiv.style.visibility = 'visible';
        loginDiv.style.visibility = 'hidden';
        registerDiv.style.visibility = 'hidden';
    } else {
        usernameDiv.style.visibility = 'hidden';
        loginDiv.style.visibility = 'visible';
        registerDiv.style.visibility = 'visible';
    }
}

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

// find main tag
let main = document.querySelector('[role="main"]');
// 

