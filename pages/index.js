import { useEffect } from 'react';
import Head from 'next/head';

export default function Home() {
  useEffect(() => {
    // Load Flutter app
    const script = document.createElement('script');
    script.src = '/flutter.js';
    script.defer = true;
    document.body.appendChild(script);

    script.onload = () => {
      window.addEventListener('load', function() {
        _flutter.loader.loadEntrypoint({
          serviceWorker: {
            serviceWorkerVersion: null,
          },
          onEntrypointLoaded: function(engineInitializer) {
            engineInitializer.initializeEngine().then(function(appRunner) {
              appRunner.runApp();
            });
          }
        });
      });
    };
  }, []);

  return (
    <div>
      <Head>
        <title>News App</title>
        <meta name="description" content="Stay informed with the latest news from around the world" />
        <link rel="icon" href="/favicon.png" />
        <base href="/" />
      </Head>

      <main>
        <div id="flutter_app"></div>
      </main>

      <style jsx global>{`
        html,
        body {
          padding: 0;
          margin: 0;
          font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen,
            Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue, sans-serif;
          height: 100%;
          width: 100%;
          overflow: hidden;
        }

        #flutter_app {
          height: 100vh;
          width: 100vw;
        }
      `}</style>
    </div>
  );
} 