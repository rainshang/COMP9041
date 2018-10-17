import { dateFormat } from './date.format.js';
/* returns an empty array of size max */
export const range = (max) => Array(max).fill(null);

/* returns a randomInteger */
export const randomInteger = (max = 1) => Math.floor(Math.random() * max);

/* returns a randomHexString */
const randomHex = () => randomInteger(256).toString(16);

/* returns a randomColor */
export const randomColor = () => '#' + range(3).map(randomHex).join('');

/**
 * You don't have to use this but it may or may not simplify element creation
 * 
 * @param {string}  tag     The HTML element desired
 * @param {any}     data    Any textContent, data associated with the element
 * @param {object}  options Any further HTML attributes specified
 */
export function createElement(tag, data, options = {}) {
    const el = document.createElement(tag);
    el.textContent = data;

    // Sets the attributes in the options object to the element
    return Object.entries(options).reduce(
        (element, [field, value]) => {
            element.setAttribute(field, value);
            return element;
        }, el);
}

/**
 * Given a post, return a tile with the relevant data
 * @param   {object}        post 
 * @returns {HTMLElement}
 */
export function createPostTile(api, post, selfId, onComment) {
    const section = createElement('section', null, { class: 'post' });

    section.appendChild(createElement('h2', post.meta.author, { class: 'post-title' }));
    section.appendChild(createElement('div', post.meta.description_text, { class: 'post-desc' }));
    section.appendChild(createElement('img', null,
        {
            src: 'data:image/jpeg;base64,' + post.src,
            alt: post.meta.description_text, class: 'post-image'
        }));

    section.appendChild(createElement('div', new Date(1000 * post.meta.published).format('yyyy-mm-dd hh:MM:ss'), { class: 'post-date' }));

    let bottomDiv = createElement('div', null, { class: 'post-bottom' })
    let likeDiv = createElement('div', null, { class: 'post-bottom-like' })
    let likeIcon = createElement('i', null, { class: 'material-icons' })
    let likeCount = createElement('span', null, { class: 'post-bottom-text' })
    likeDiv.appendChild(likeIcon);
    likeDiv.appendChild(likeCount);
    bottomDiv.appendChild(likeDiv);
    let likeNames = createElement('div', null, { class: 'post-bottom-like-name' });
    bottomDiv.appendChild(likeNames);
    likeIcon.addEventListener('click', () => {
        if (post.meta.likes.includes(selfId)) {
            api.unlike(post.id)
                .then(res => {
                    if ((/Success/i).test(res.message)) {
                        post.meta.likes.splice(post.meta.likes.indexOf(selfId), 1);
                        refreshLike();
                    }
                })
        } else {
            api.like(post.id)
                .then(res => {
                    if ((/Success/i).test(res.message)) {
                        post.meta.likes.push(selfId);
                        refreshLike();
                    }
                })
        }
    });
    let refreshLike = () => {
        likeIcon.textContent = post.meta.likes.includes(selfId) ? 'favorite' : 'favorite_border';
        likeCount.textContent = post.meta.likes.length;
        likeNames.textContent = '';
        post.meta.likes.forEach(uid => {
            api.getUser(null, uid)
                .then(res => {
                    if (likeNames.textContent) {
                        likeNames.textContent += `, ${res.name}`;
                    } else {
                        likeNames.textContent += res.name;
                    }
                })
        });
    };
    refreshLike();
    section.appendChild(bottomDiv);

    let bottomDiv2 = createElement('div', null, { class: 'post-bottom' })
    let commentDiv = createElement('div', null, { class: 'post-bottom-comment' })
    let commentIcon = createElement('i', 'chat_bubble_outline', { class: 'material-icons' })
    let commentCount = createElement('span', null, { class: 'post-bottom-text' })
    commentDiv.appendChild(commentIcon);
    commentDiv.appendChild(commentCount);
    bottomDiv2.appendChild(commentDiv);
    let commentList = createElement('div', null, { class: 'post-bottom-comment-list' });
    bottomDiv2.appendChild(commentList);
    let refreshComment = () => {
        commentCount.textContent = post.comments.length;
        commentList.textContent = '';
        if (post.comments.length) {
            bottomDiv2.appendChild(commentList);
            post.comments.forEach(comment => {
                let item = createElement('div', null, { class: 'post-bottom-comment-list-item' });
                item.innerHTML = `<font color='royalblue'><b>${comment.author}:</b></font> ${comment.comment}`;
                commentList.appendChild(item);
            });
        } else {
            bottomDiv2.removeChild(commentList);
        }
    };
    commentIcon.addEventListener('click', () => {
        if (onComment) {
            onComment(post.id, (comment) => {
                post.comments.push(comment);
                refreshComment();
            });
        }
    });
    refreshComment();
    section.appendChild(bottomDiv2);

    return section;
}

// Given an input element of type=file, grab the data uploaded for use
export function uploadImage(event, onImgRead) {
    const [file] = event.target.files;

    // const validFileTypes = ['image/jpeg', 'image/png', 'image/jpg']
    const validFileTypes = ['image/png']
    const valid = validFileTypes.find(type => type === file.type);

    // bad data, let's walk away
    if (!valid)
        return false;

    // if we get here we have a valid image
    const reader = new FileReader();

    reader.onload = (e) => {
        // do something with the data result
        onImgRead(e.target.result);
    };

    // this returns a base64 image
    reader.readAsDataURL(file);
}

/* 
    Reminder about localStorage
    window.localStorage.setItem('AUTH_KEY', someKey);
    window.localStorage.getItem('AUTH_KEY');
    localStorage.clear()
*/
export function checkStore(key) {
    if (window.localStorage)
        return window.localStorage.getItem(key)
    else
        return null

}