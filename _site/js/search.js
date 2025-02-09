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