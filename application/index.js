require('dotenv').config();
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';

// GET /health endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// GET /predict endpoint
app.get('/predict', (req, res) => {
  res.json({ score: 0.75 });
});

// Start the server
app.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
});
