export default async function handler(req, res) {
  const { NEWS_API_KEY } = process.env;
  
  if (!NEWS_API_KEY) {
    return res.status(500).json({ error: 'API key not configured' });
  }

  try {
    const response = await fetch(
      `https://newsapi.org/v2/top-headlines?country=us&apiKey=${NEWS_API_KEY}`
    );
    const data = await response.json();
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch news' });
  }
} 