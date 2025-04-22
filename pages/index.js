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
      window._flutter = window._flutter || {};
      window._flutter.loader = window._flutter.loader || {};
      
      window._flutter.loader.loadEntrypoint({
        entrypointUrl: "/main.dart.js",
        serviceWorker: {
          serviceWorkerUrl: "/flutter_service_worker.js",
          serviceWorkerVersion: null,
        },
        onEntrypointLoaded: async function(engineInitializer) {
          const appRunner = await engineInitializer.initializeEngine({
            hostElement: document.querySelector('#flutter_app'),
            assetBase: "/"
          });
          await appRunner.runApp();
        }
      });
    };

    return () => {
      // Cleanup
      document.body.removeChild(script);
    };
  }, []);

  return (
    <div>
      <Head>
        <title>News App</title>
        <meta name="description" content="Stay informed with the latest news from around the world" />
        <link rel="icon" href="/favicon.png" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
      </Head>

      <main style={{ height: '100vh', width: '100vw', overflow: 'hidden' }}>
        <div id="flutter_app" style={{ height: '100%', width: '100%' }}></div>
      </main>

      <style jsx global>{`
        html,
        body {
          padding: 0;
          margin: 0;
          height: 100%;
          width: 100%;
          overflow: hidden;
        }
      `}</style>
    </div>
  );
} 