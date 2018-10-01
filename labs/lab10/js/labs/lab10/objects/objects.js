/*
 * Fill out the Person prototype
 * function "buyDrink" which given a drink object which looks like:
 * {
 *     name: "beer",
 *     cost: 8.50,
 *     alcohol: true
 * }
 * will add the cost to the person expences if the person
 * is
 *    1. old enough to drink (if the drink is alcohol)
 *    2. buying the drink will not push their tab over $1000
 *
 * in addition write a function "getRecipt" which returns a list as such
 * [
 *    {
 *        name: beer,
 *        count: 3,
 *        cost: 25.50
 *    }
 * ]
 *
 * which summaries all drinks a person bought by name in order
 * of when they were bought (duplicate buys are stacked)
 *
 * run with `node test.js <name> <age> <drinks file>`
 * i.e
 * `node test.js alex 76 drinks.json`
 */

function Person(name, age) {
  this.name = name;
  this.age = age;
  this.tab = 0;
  this.history = {};
  this.historyLen = 0;
  this.canDrink = function () {
    return this.age >= 18;
  };
  this.canSpend = function (cost) {
    return this.tab + cost <= 1000;
  }
}

Person.prototype.buyDrink = function (drink) {
  if (drink.alcohol && !this.canDrink()) {
    return;
  }
  if (this.canSpend(drink.cost)) {
    if (this.history[drink.name]) {
      this.history[drink.name] = {
        count: this.history[drink.name].count + 1,
        total: this.history[drink.name].total + drink.cost
      }
    } else {
      this.history[drink.name] = {
        count: 1,
        total: drink.cost
      }
    }
    this.historyLen++;
    this.tab += drink.cost;
  }
}

Person.prototype.getRecipt = function () {
  let recipt = [];
  for (const key in this.history) {
    const element = this.history[key];
    recipt.push({
      name: key,
      count: element.count,
      total: element.total
    });
  }
  return recipt;
}

module.exports = Person;
