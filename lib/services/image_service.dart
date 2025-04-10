import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageService {
  static String getProxiedUrl(String originalUrl) {
    if (kIsWeb) {
      // For web, use a different approach
      // Return the original URL and handle errors in the widget
      return originalUrl;
    }
    return originalUrl;
  }
  
  static Future<bool> isImageAvailable(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking image availability: $e');
      return false;
    }
  }
} 