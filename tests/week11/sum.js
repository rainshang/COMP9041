
function sum(list) {
  let sum = 0;
  list.forEach(item => sum += parseInt(item));
  return sum;
}

module.exports = sum;
