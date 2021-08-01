var autocomplete = new kt.OsmNamesAutocomplete(
    'search', 'https://api.yourdomain.com/');

autocomplete.registerCallback(function(item) {
  alert(JSON.stringify(item, ' ', 2));
});