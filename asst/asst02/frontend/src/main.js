// importing named exports we use brackets
import { createPostTile, uploadImage } from './helpers.js';

// when importing 'default' exports, use below syntax
import API from './api.js';

const api = new API();

// get nav items
let loggedinDiv = document.getElementById('loggedin-area');
let unloggedinDiv = document.getElementById('unloggedin-area');

let userInfo;

let loginDialog = document.querySelector('[role="login"]');
let registerDialog = document.querySelector('[role="register"]');
let commentDialog = document.querySelector('[role="comment"]');
let commentInput = document.getElementById('comment-input');
let newPostDialog = document.querySelector('[role="new-post"]');
let newPostFile = document.querySelector('input[type="file"]');
let newPostImg = document.getElementById('new-post-dialog-img');
let newPostInput = document.getElementById('new-post-input');

let loading = document.getElementById('loading');
let nextPageBtn = document.querySelector('[class="next-page"]');
let currentP = 0;

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
        .then(res => {
            if (res.token) {
                setCookie('token', res.token, 30);
                refreshNav();
                loginDialog.style.display = 'none';
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
        .then(res => {
            if (res.token) {
                setCookie('token', res.token, 30);
                refreshNav();
                registerDialog.style.display = 'none';
            }
        });
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




document.getElementById('new-post').onclick = () => {
    newPostFile.value = '';
    newPostImg.src = '';
    newPostInput.value = '';
    newPostDialog.style.display = 'block';
};
document.getElementById('new-post-dialog-close').onclick = () => {
    newPostDialog.style.display = 'none';
};
document.getElementById('new-post-dialog-btn').onclick = () => {
    if (newPostInput.value && newPostImg.src.startsWith('data:image/')) {
        api.post(newPostInput.value, newPostImg.src.split('base64,')[1])
            .then(res => {
                if (res.post_id) {
                    document.getElementById('user-pop-posts').innerText = userInfo.posts.length + 1;
                    newPostDialog.style.display = 'none';
                } else {
                    console.error(res.message);
                }
            });
    }
};
newPostDialog = document.querySelector('[role="new-post"]');
newPostFile.addEventListener('change', e => uploadImage(e, img => {
    newPostImg.src = img;
}));

document.getElementById('logout').onclick = () => {
    setCookie('token', '', 0);
    refreshNav();
};

nextPageBtn.onclick = () => {
    fetchFeed();
};

refreshNav();

function refreshNav() {
    let token = getCookie('token');
    currentP = 0;
    document.getElementById('large-feed').innerHTML = '';
    loading.style.display = 'block';
    nextPageBtn.style.display = 'none';
    if (token) {
        api.setToken(token);
        console.log(token);
        api.getUser()
            .then(res => {
                userInfo = res;
                document.getElementById('username').innerText = userInfo.name;
                document.getElementById('user-pop-username').innerText = userInfo.username;
                document.getElementById('user-pop-email').innerText = userInfo.email;
                document.getElementById('user-pop-name').innerText = userInfo.name;
                document.getElementById('user-pop-posts').innerText = userInfo.posts.length;
                document.getElementById('user-pop-following').innerText = userInfo.following.length;
                document.getElementById('user-pop-followed').innerText = userInfo.followed_num;
                fetchFeed();
            });
        loggedinDiv.style.display = 'block';
        unloggedinDiv.style.display = 'none';
    } else {
        loading.style.display = 'none';
        nextPageBtn.style.display = 'none';
        loggedinDiv.style.display = 'none';
        unloggedinDiv.style.display = 'block';
    }
}

function fetchFeed() {
    loading.style.display = 'block';
    nextPageBtn.style.display = 'none';
    api.getFeed(currentP, 2)
        .then(result => result.posts)
        .then(posts => {
            posts.reduce((parent, post) => {
                parent.appendChild(createPostTile(api, post, userInfo.id, onComment));
                return parent;
            }, document.getElementById('large-feed'));
            loading.style.display = 'none';
            nextPageBtn.style.display = 'block';
            currentP += posts.length;
        })
        .catch(() => {
            loading.style.display = 'none';
            nextPageBtn.style.display = 'block';
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
