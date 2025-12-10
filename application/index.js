const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// Access secrets via environment variables (injected by ECS)
const DATABASE_URL = process.env.DATABASE_URL;
const API_KEY = process.env.API_KEY;
const JWT_SECRET = process.env.JWT_SECRET;

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
