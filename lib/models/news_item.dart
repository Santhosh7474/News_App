class NewsItem {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String author;
  final String source;
  final String publishedAt;
  final String category;
  final String readTime;
  final int views;
  final String articleUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.source,
    required this.publishedAt,
    required this.category,
    this.readTime = '5 min',
    this.views = 0,
    this.articleUrl = '',
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'] ?? '',
      source: json['source'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      category: json['category'] ?? '',
      readTime: json['readTime'] ?? '5 min',
      views: json['views'] ?? 0,
      articleUrl: json['articleUrl'] ?? '',
    );
  }
}
