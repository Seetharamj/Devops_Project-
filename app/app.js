const express = require('express');
const promClient = require('prom-client');

const app = express();
const PORT = 3000;

// Metrics setup
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics();

const counter = new promClient.Counter({
  name: 'web_requests_total',
  help: 'Total number of web requests',
});

app.get('/', (req, res) => {
  counter.inc();
  res.send('Hello from DevOps Project!');
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});

app.listen(PORT, () => {
  console.log(`App running on http://localhost:${PORT}`);
});
