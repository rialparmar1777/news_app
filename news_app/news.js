// Vercel serverless function to proxy News API requests
const fetch = require('node-fetch');

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // Only allow GET requests
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { category, query } = req.query;
    const apiKey = process.env.NEWS_API_KEY;
    
    if (!apiKey) {
      throw new Error('NEWS_API_KEY environment variable is not set');
    }

    // Construct the News API URL
    let url;
    if (query) {
      url = `https://newsapi.org/v2/everything?q=${encodeURIComponent(query)}&apiKey=${apiKey}`;
    } else {
      url = `https://newsapi.org/v2/top-headlines?country=us&category=${category || 'general'}&apiKey=${apiKey}`;
    }

    // Fetch data from News API
    const response = await fetch(url);
    const data = await response.json();

    // Return the data
    res.status(200).json(data);
  } catch (error) {
    console.error('Error fetching news:', error);
    res.status(500).json({ error: error.message });
  }
}; 