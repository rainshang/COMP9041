// importing named exports we use brackets
import { createPostTile, uploadImage } from './helpers.js';

// when importing 'default' exports, use below syntax
import API from './api.js';

const api = new API();

// // Potential example to upload an image
// const input = document.querySelector('input[type="file"]');

// input.addEventListener('change', uploadImage);

// get nav items
let loggedinDiv = document.getElementById('loggedin-area');
let unloggedinDiv = document.getElementById('unloggedin-area');

let loginDialog = document.querySelector('[role="login"]');
let registerDialog = document.querySelector('[role="register"]');
let commentDialog = document.querySelector('[role="comment"]');
let commentInput = document.getElementById('comment-input');

document.getElementById('login').onclick = () => {
    loginDialog.style.display = 'block';
};
document.getElementById('login-dialog-close').onclick = () => {
    loginDialog.style.display = 'none';
};
document.getElementById('login-dialog-btn').onclick = () => {
    api.login(
        document.forms['login-form']['username'].value,
        document.forms['login-form']['password'].value)
        .then(r1 => {
            if (r1.token) {
                api.setToken(r1.token);
                api.getUser()
                    .then(r2 => {
                        onGetUnserInfo(r1.token, r2);
                        loginDialog.style.display = 'none';
                    })
            }
        });
};

document.getElementById('register').onclick = () => {
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
        .then(r1 => {
            if (r1.token) {
                api.setToken(r1.token);
                api.getUser()
                    .then(r2 => {
                        onGetUnserInfo(r1.token, r2);
                        registerDialog.style.display = 'none';
                    })
            }
        })
};

document.getElementById('comment-dialog-close').onclick = () => {
    commentDialog.style.display = 'none';
};
document.getElementById('comment-dialog-btn').onclick = () => {
    if (commentInput.value) {
        let author = JSON.parse(getCookie('userInfo')).name;
        api.comment(commentInput.pid, author, commentInput.value)
            .then(res => {
                if ((/Success/i).test(res.message)) {
                    commentInput.onCommentSucess({
                        author: author,
                        published: new Date().getTime() / 1000,
                        comment: commentInput.value,
                    });
                    commentDialog.style.display = 'none';
                }
            });
    }
};

document.getElementById('logout').onclick = () => {
    setCookie('token', '', 0);
    setCookie('userInfo', '', 0);
    refreshNav();
};

refreshNav();

function refreshNav() {
    let token = getCookie('token');
    if (token) {
        api.setToken(token);
        console.log(token)
        let userInfo = JSON.parse(getCookie('userInfo'));
        let usernameDiv = document.getElementById('username');
        usernameDiv.innerHTML = userInfo.name + usernameDiv.innerHTML;
        document.getElementById('user-pop-username').innerText = userInfo.username;
        document.getElementById('user-pop-email').innerText = userInfo.email;
        document.getElementById('user-pop-name').innerText = userInfo.name;
        document.getElementById('user-pop-posts').innerText = userInfo.posts.length;
        document.getElementById('user-pop-following').innerText = userInfo.following.length;
        document.getElementById('user-pop-followed').innerText = userInfo.followed_num;

        loggedinDiv.style.display = 'block';
        unloggedinDiv.style.display = 'none';
        fetchFeed();
    } else {
        loggedinDiv.style.display = 'none';
        unloggedinDiv.style.display = 'block';
        document.getElementById('large-feed').innerHTML = '';
    }
}

function onGetUnserInfo(token, userInfo) {
    setCookie('token', token, 30);
    setCookie('userInfo', JSON.stringify(userInfo), 30);
    refreshNav();
}


function fetchFeed() {
    let userInfo = JSON.parse(getCookie('userInfo'));
    api.getFeed()
        .then(result => result.posts)
        .then(posts => {
            posts.reduce((parent, post) => {
                parent.appendChild(createPostTile(api, post, userInfo.id, onComment));
                return parent;
            }, document.getElementById('large-feed'))
        });
}

function onComment(pid, onCommentSucess) {
    commentInput.pid = pid;
    commentInput.value = '';
    commentInput.onCommentSucess = onCommentSucess;
    commentDialog.style.display = 'block';
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
