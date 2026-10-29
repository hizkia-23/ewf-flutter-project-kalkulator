class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.imageUrl,
    this.source = 'TradingView / Market',
    this.url = '',
    this.snippet = '',
  });

  final String id;
  final String title;
  final String category;
  final String timeAgo;
  final String imageUrl;
  final String source;
  final String url;
  final String snippet;

  /// Kebal terhadap obfuscation R8 (ProGuard) & null safety
  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      timeAgo: map['timeAgo']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      source: map['source']?.toString() ?? 'TradingView / Market',
      url: map['url']?.toString() ?? '',
      snippet: map['snippet']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'timeAgo': timeAgo,
      'imageUrl': imageUrl,
      'source': source,
      'url': url,
      'snippet': snippet,
    };
  }
}

