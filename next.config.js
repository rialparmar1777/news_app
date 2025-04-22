/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  webpack: (config, { isServer }) => {
    // Add support for Flutter web assets
    config.module.rules.push({
      test: /\.(js|wasm)$/,
      type: 'asset/resource',
    });

    return config;
  },
  // Ensure static files are served from the public directory
  async rewrites() {
    return [
      {
        source: '/flutter.js',
        destination: '/public/flutter.js',
      },
      {
        source: '/main.dart.js',
        destination: '/public/main.dart.js',
      },
      {
        source: '/flutter_service_worker.js',
        destination: '/public/flutter_service_worker.js',
      },
      {
        source: '/assets/:path*',
        destination: '/public/assets/:path*',
      },
      {
        source: '/icons/:path*',
        destination: '/public/icons/:path*',
      },
    ];
  },
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig; 