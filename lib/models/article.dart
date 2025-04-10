class Article {
  final String title;
  final String? description;
  final String? content;
  final String url;
  final String? urlToImage;
  final String source;
  final String publishedAt;
  final String? author;

  Article({
    required this.title,
    this.description,
    this.content,
    required this.url,
    this.urlToImage,
    required this.source,
    required this.publishedAt,
    this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // Handle source which can be either a string or an object with a 'name' property
    String sourceName = '';
    if (json['source'] != null) {
      if (json['source'] is String) {
        sourceName = json['source'];
      } else if (json['source'] is Map) {
        sourceName = json['source']['name'] ?? '';
      }
    }

    return Article(
      title: json['title'] ?? '',
      description: json['description'],
      content: json['content'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      source: sourceName,
      publishedAt: json['publishedAt'] ?? '',
      author: json['author'],
    );
  }
} 