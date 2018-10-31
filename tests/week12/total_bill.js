function total_bill(bill_list) {
  let sum = 0;
  bill_list.forEach(element1 => {
    element1.forEach(element2 => {
      sum += parseFloat(element2.price.slice(1));
    });
  });
  return sum;
}

module.exports = total_bill;
