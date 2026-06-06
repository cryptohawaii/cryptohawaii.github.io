/*
// assets/js/search.js
(function() {
    var searchInput = document.getElementById('search-input');
    var resultsContainer = document.getElementById('results-container');
  
    searchInput.addEventListener('input', function() {
      var query = searchInput.value.toLowerCase();
      fetch('/search.json')
        .then(response => response.json())
        .then(posts => {
          var results = posts.filter(post => post.title.toLowerCase().includes(query) || post.content.toLowerCase().includes(query));
          resultsContainer.innerHTML = results.map(post => `<li><a href="${post.url}">${post.title}</a></li>`).join('');
        });
    });
  })();
  
*/

document.addEventListener('DOMContentLoaded', function() {
  SimpleJekyllSearch({
    searchInput: document.getElementById('search-input'),
    resultsContainer: document.getElementById('results-container'),
    json: '/search.json',
    searchResultTemplate: '<li><a href="{url}">{title}</a></li>',
    noResultsText: 'No results found',
    limit: 10,
    fuzzy: false
  });
});
/*
document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM fully loaded and parsed');
  
  SimpleJekyllSearch({
    searchInput: document.getElementById('search-input'),
    resultsContainer: document.getElementById('results-container'),
    json: '/search.json',
    searchResultTemplate: '<li><a href="{url}">{title}</a></li>',
    noResultsText: 'No results found',
    limit: 10,
    fuzzy: false
  });

  console.log('SimpleJekyllSearch initialized');
});
*/