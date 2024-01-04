document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search");
  const suggestionBox = document.getElementById("suggestions");
  const userIdentifierInput = document.getElementById("userIdentifier"); // Change the variable name
  const userIdentifier = userIdentifierInput.dataset.identifier; // Retrieve user identifier from the data attribute

  let typingTimer;
  const doneTypingInterval = 500; // 500 milliseconds

  searchInput.addEventListener("input", function () {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(handleSearch, doneTypingInterval);
  });

  function handleSearch() {
    const query = searchInput.value;

    // POST request to /search
    fetch("/search", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        query: query,
        userIdentifier: userIdentifier, // Change the parameter name
      }),
    });

    // GET request to /get_similar_queries
    fetch(
      `/get_similar_queries?query=${encodeURIComponent(
        query
      )}&user_identifier=${encodeURIComponent(userIdentifier)}` // Change the parameter name
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
});
