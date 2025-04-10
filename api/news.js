// Vercel serverless function to proxy News API requests
import axios from 'axios';

// Simple in-memory rate limiting
const rateLimit = new Map();
const RATE_LIMIT_WINDOW = 60 * 1000; // 1 minute
const MAX_REQUESTS = 30; // 30 requests per minute

const isRateLimited = (ip) => {
  const now = Date.now();
  const userRequests = rateLimit.get(ip) || [];
  const recentRequests = userRequests.filter(time => now - time < RATE_LIMIT_WINDOW);
  
  if (recentRequests.length >= MAX_REQUESTS) {
    return true;
  }
  
  recentRequests.push(now);
  rateLimit.set(ip, recentRequests);
  return false;
};

export default async function handler(req, res) {
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

  // Rate limiting
  const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  if (isRateLimited(clientIp)) {
    res.status(429).json({ error: 'Too many requests. Please try again later.' });
    return;
  }

  try {
    const { category = 'general', pageSize = 20 } = req.query;
    const apiKey = process.env.NEWS_API_KEY;
    const baseUrl = process.env.NEWS_API_BASE_URL || 'https://newsapi.org/v2';
    
    if (!apiKey) {
      console.error('API key is missing');
      throw new Error('NEWS_API_KEY environment variable is not set');
    }

    // Validate pageSize
    const validatedPageSize = Math.min(Math.max(1, parseInt(pageSize)), 100);

    // Construct the News API URL
    let url;
    url = `${baseUrl}/top-headlines?country=us&category=${category}&pageSize=${validatedPageSize}&apiKey=${apiKey}`;

    console.log(`[${new Date().toISOString()}] Fetching from URL: ${url.replace(apiKey, 'API_KEY_HIDDEN')}`);

    // Fetch data from News API
    const response = await axios.get(url, {
      headers: {
        'X-Api-Key': apiKey,
      },
    });

    console.log(`[${new Date().toISOString()}] Response status: ${response.status}`);
    console.log(`[${new Date().toISOString()}] Number of articles: ${response.data.articles ? response.data.articles.length : 0}`);
    console.log(`[${new Date().toISOString()}] API response status: ${response.data.status}`);

    if (!response.data.ok) {
      throw new Error(`News API responded with status ${response.status}: ${response.data.message || 'Unknown error'}`);
    }

    if (response.data.status !== 'ok') {
      console.error('API Error:', response.data);
      throw new Error(response.data.message || 'Failed to fetch news');
    }

    // Return the data with additional metadata
    res.status(200).json({
      ...response.data,
      metadata: {
        timestamp: new Date().toISOString(),
        pageSize: validatedPageSize,
        totalResults: response.data.totalResults,
        category: category,
      }
    });
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error fetching news:`, error);
    
    // Handle specific error types
    if (error.message.includes('API key')) {
      res.status(500).json({ error: 'Server configuration error. Please contact support.' });
    } else if (error.message.includes('429')) {
      res.status(429).json({ error: 'News API rate limit exceeded. Please try again later.' });
    } else {
      res.status(error.response?.status || 500).json({
        error: error.response?.data?.message || 'Failed to fetch news',
      });
    }
  }
} 