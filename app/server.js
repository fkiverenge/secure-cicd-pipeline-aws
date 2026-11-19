const http = require("http");

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || "local";

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(`<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Secure CI/CD Demo</title></head>
<body style="font-family: sans-serif; max-width: 640px; margin: 4rem auto;">
  <h1>Secure CI/CD pipeline demo</h1>
  <p>This container was built, scanned and deployed to Amazon ECS by GitHub Actions.</p>
  <p>Version (git commit): <code>${VERSION}</code></p>
  <p>Enjoy!</p>
</body>
</html>`);
});

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
