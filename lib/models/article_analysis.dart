class ArticleAnalysis {
  final String summary;
  final String perspectives;
  final String biases;
  final String verification;
  final DateTime timestamp;

  ArticleAnalysis({
    required this.summary,
    required this.perspectives,
    required this.biases,
    required this.verification,
    required this.timestamp,
  });

  factory ArticleAnalysis.fromJson(Map<String, dynamic> json) {
    return ArticleAnalysis(
      summary: json['summary'] ?? '',
      perspectives: json['perspectives'] ?? '',
      biases: json['biases'] ?? '',
      verification: json['verification'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'perspectives': perspectives,
      'biases': biases,
      'verification': verification,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 