(function() {
  'use strict';
  // TODO: Write some js
  let clickListener = (btn) => {
    let icon = btn.getElementsByTagName('i')[0];
    let i = icon.id.substring(5);
    if ('expand_less' == icon.textContent) {
      document.getElementById(`item-${i}-content`).style.display = 'none';
      icon.textContent = 'expand_more';
    } else {
      document.getElementById(`item-${i}-content`).style.display = 'block';
      icon.textContent = 'expand_less';
    }
  }
  Array.from(document.getElementsByClassName('expand-collapse-btn')).forEach(btn => {
    btn.addEventListener('click', () => clickListener(btn));
  });
}());
