// index.js
import http from 'http';
const port = process.env.PORT || 8080;
http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('DevOps Release Lab container is running!\n');
}).listen(port, () => console.log(`Server listening on ${port}`));
