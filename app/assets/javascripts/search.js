document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search");
  const suggestionBox = document.getElementById("suggestions");

  let typingTimer;
  const doneTypingInterval = 500; // 500 milliseconds

  async function getIp() {
    try {
      const response = await fetch("https://ipinfo.io/json");
      const data = await response.json();
      return data.ip;
    } catch (error) {
      console.error("Error fetching IP:", error);
      return null;
    }
  }

  searchInput.addEventListener("input", function () {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(handleSearch, doneTypingInterval);
  });

  async function handleSearch() {
    const query = searchInput.value;

    // Fetch the client's IP address
    const userIp = await getIp();

    if (!userIp) {
      console.error("Unable to fetch IP address");
      return;
    }

    // POST request to /search with userIp in headers
    fetch("/search", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-User-Ip": userIp,
      },
      body: JSON.stringify({
        query: query,
      }),
    });

    // GET request to /get_similar_queries with userIp in headers
    fetch(`/get_similar_queries?query=${encodeURIComponent(query)}`, {
      headers: {
        "X-User-Ip": userIp,
      },
    })
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
