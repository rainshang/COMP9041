// change this when you integrate with the real API, or when u start using the dev server
// const API_URL = 'http://login.cse.unsw.edu.au:8007'
const API_URL = 'http://localhost:5000'

const getJSON = (path, options) =>
    fetch(path, options)
        .then(res => res.json())
        .catch(err => console.warn(`API_ERROR: ${err.message}`));

const getQuerySuffix = (url, params) => {
    if (params && Object.keys(params).length) {
        return url + '?' + Object.keys(params)
            .map(k => encodeURIComponent(k) + '=' + encodeURIComponent(params[k]))
            .join('&');
    } else {
        return url;
    }
}

/**
 * This is a sample class API which you may base your code on.
 * You don't have to do this as a class.
 */
export default class API {

    /**
     * Defaults to teh API URL
     * @param {string} url 
     */
    constructor(url = API_URL) {
        this.url = url;
    }

    makeAPIRequest(path, options) {
        return getJSON(`${this.url}/${path}`, options);
    }

    login(username, password) {
        return this.makeAPIRequest('auth/login', {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
            },
            method: 'POST',
            body: JSON.stringify({
                username: username,
                password: password,
            })
        });
    }

    register(username, password, email, name) {
        return this.makeAPIRequest('auth/signup', {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
            },
            method: 'POST',
            body: JSON.stringify({
                username: username,
                password: password,
                email: email,
                name: name,
            })
        });
    }

    setToken(token) {
        this.token = token;
    }

    getUser(username, id) {
        let params = {};
        if (username) {
            params.username = username;
        }
        if (id) {
            params.id = id;
        }
        return this.makeAPIRequest(getQuerySuffix('user/', params), {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Token ${this.token}`,
            },
            method: 'GET',
        });
    }

    getFeed(p, n) {
        let params = {};
        if (p) {
            params.p = p;
        }
        if (n) {
            params.n = n;
        }
        return this.makeAPIRequest(getQuerySuffix('user/feed', params), {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Token ${this.token}`,
            },
            method: 'GET',
        });
    }

    like(pid) {
        return this.makeAPIRequest(`post/like?id=${pid}`, {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Token ${this.token}`,
            },
            method: 'PUT',
        });
    }

    unlike(pid) {
        return this.makeAPIRequest(`post/unlike?id=${pid}`, {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Token ${this.token}`,
            },
            method: 'PUT',
        });
    }

    comment(pid, author, comment) {
        return this.makeAPIRequest(`post/comment?id=${pid}`, {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Token ${this.token}`,
            },
            method: 'PUT',
            body: JSON.stringify({
                author: author,
                published: new Date().getTime() / 1000,
                comment: comment,
            })
        });
    }

    post(desc, img_base64) {
        return this.makeAPIRequest('post', {
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Token ${this.token}`,
            },
            method: 'POST',
            body: JSON.stringify({
                description_text: desc,
                src: img_base64,
            })
        });
    }

}
