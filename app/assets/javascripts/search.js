document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search");
  const suggestionBox = document.getElementById("suggestions");
  const userIpInput = document.getElementById("userIp");

  let typingTimer;
  const doneTypingInterval = 500; // 500 milliseconds

  searchInput.addEventListener("input", function () {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(handleSearch, doneTypingInterval);
  });

  function handleSearch() {
    const query = searchInput.value;

    // Get the client's IP address
    fetch("https://api.ipify.org?format=json")
      .then((response) => response.json())
      .then((data) => {
        const userIp = data.ip; // Retrieve user's IP from the response

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
          )}&user_ip=${encodeURIComponent(userIp)}`
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
      });
  }
});
