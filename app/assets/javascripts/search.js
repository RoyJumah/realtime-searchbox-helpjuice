document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search");
  const suggestionBox = document.getElementById("suggestions");
  const userIpInput = document.getElementById("userIp");
  const searchHistoryBody = document.getElementById("search-history-body");

  let typingTimer;
  const doneTypingInterval = 500; // 500 milliseconds

  searchInput.addEventListener("input", function () {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(handleSearch, doneTypingInterval);
  });

  function handleSearch() {
    const query = searchInput.value;
    const userIp = userIpInput.dataset.ip; // Retrieve user's IP from the data attribute

    // POST request to /search
    fetch("/search", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        query: query,
        userIp: userIp,
      }),
    });

    // GET request to /get_similar_queries
    fetch(
      `/get_similar_queries?query=${encodeURIComponent(
        query
      )}&user_ip=${encodeURIComponent(userIpInput.dataset.ip)}`
    )
      .then((response) => response.json())
      .then((data) => {
        // Update the suggestion box
        suggestionBox.innerHTML = "";
        const ul = document.createElement("ul");
        data.similar_queries.forEach((suggestion) => {
          const li = document.createElement("li");
          li.textContent = suggestion;
          ul.appendChild(li);
        });
        suggestionBox.appendChild(ul);
        if (data.similar_queries.length > 0) {
          suggestionBox.style.setProperty("display", "block", "important");
        } else {
          suggestionBox.style.setProperty("display", "none", "important");
        }
      });
  }

  // getting search history
  function fetchSearchHistory() {
    const userIp = userIpInput.dataset.ip; // Retrieve user's IP from the data attribute

    // GET request to /search_queries/history
    fetch(`/search_queries/history?user_ip=${encodeURIComponent(userIp)}`)
      .then((response) => response.json())
      .then((data) => {
        // Update the search history table
        searchHistoryBody.innerHTML = ""; // Clear the table body
        data.search_history.forEach((query) => {
          const tr = document.createElement("tr");
          const td = document.createElement("td");
          td.textContent = query;
          tr.appendChild(td);
          searchHistoryBody.appendChild(tr);
        });
      });
  }

  // Fetch the search history when the page loads
  fetchSearchHistory();
});
