const request = require('supertest');
const express = require('express');

// Create app instance for testing
const app = express();

// GET /health endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// GET /predict endpoint
app.get('/predict', (req, res) => {
  res.json({ score: 0.75 });
});

describe('API Endpoints', () => {
  test('GET /health should return status ok', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });

  test('GET /predict should return score', async () => {
    const response = await request(app).get('/predict');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ score: 0.75 });
  });

  test('GET /nonexistent should return 404', async () => {
    const response = await request(app).get('/nonexistent');
    expect(response.status).toBe(404);
  });
});