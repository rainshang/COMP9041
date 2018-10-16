function species_count(target_species, whale_list) {
  let count = 0;
  whale_list.forEach(element => {
    if (element.species === target_species) {
      count += element.how_many;
    }
  });
  return count;
}

module.exports = species_count;
