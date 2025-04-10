import { useState, useEffect } from 'react';
import Head from 'next/head';
import styles from '../styles/Home.module.css';

export default function HomePage() {
  const [news, setNews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchNews = async () => {
      try {
        const response = await fetch('/api/news');
        if (!response.ok) {
          throw new Error('Failed to fetch news');
        }
        const data = await response.json();
        setNews(data.articles);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchNews();
  }, []);

  if (loading) return <div className={styles.container}>Loading...</div>;
  if (error) return <div className={styles.container}>Error: {error}</div>;

  return (
    <div className={styles.container}>
      <Head>
        <title>News App</title>
        <meta name="description" content="Latest news from around the world" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>Latest News</h1>
        <div className={styles.grid}>
          {news.map((article, index) => (
            <div key={index} className={styles.card}>
              {article.urlToImage && (
                <img
                  src={article.urlToImage}
                  alt={article.title}
                  className={styles.image}
                />
              )}
              <h2>{article.title}</h2>
              <p>{article.description}</p>
              <a href={article.url} target="_blank" rel="noopener noreferrer">
                Read more →
              </a>
            </div>
          ))}
        </div>
      </main>

      <footer className={styles.footer}>
        <p>Powered by News API</p>
      </footer>
    </div>
  );
} 