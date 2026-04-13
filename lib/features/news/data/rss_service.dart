import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../../models/news_item.dart';

class RssService {
  final String languageCode;

  RssService({this.languageCode = 'en-IN'});

  // Google News RSS – category → topic token
  // The `hl` (host language) and `gl` (country) are injected from languageCode.
  // languageCode format: "en-IN", "hi-IN", "ta-IN", "te-IN", "fr-FR", etc.
  static const Map<String, String> _categoryTopics = {
    'Top':         'https://news.google.com/rss?hl={hl}&gl={gl}&ceid={ceid}',
    'World':       'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGx1YlY4U0FtVnVHZ0pKVGlnQVAB?hl={hl}&gl={gl}&ceid={ceid}',
    'Nation':      'https://news.google.com/rss/topics/CAAqIggKIhxDQkFTRHdvSkwyMHZNRGxqTjNjd0VnSmxiaWdBUAE?hl={hl}&gl={gl}&ceid={ceid}',
    'Business':    'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGx6TVdZU0FtVnVHZ0pKVGlnQVAB?hl={hl}&gl={gl}&ceid={ceid}',
    'Technology':  'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGRqTVhZU0FtVnVHZ0pKVGlnQVAB?hl={hl}&gl={gl}&ceid={ceid}',
    'Entertainment': 'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNREpxYW5RU0FtVnVHZ0pKVGlnQVAB?hl={hl}&gl={gl}&ceid={ceid}',
    'Sports':      'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRFp1ZEdvU0FtVnVHZ0pKVGlnQVAB?hl={hl}&gl={gl}&ceid={ceid}',
    'Science':     'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRFp0Y1RjU0FtVnVHZ0pKVGlnQVAB?hl={hl}&gl={gl}&ceid={ceid}',
    'Health':      'https://news.google.com/rss/topics/CAAqIQgKIhtDQkFTRGdvSUwyMHZNR3QwTlRFU0FtVnVLQUFQAQ?hl={hl}&gl={gl}&ceid={ceid}',
  };

  /// Returns all available category names
  static Map<String, String> get categoryFeeds => _categoryTopics;

  String _buildUrl(String template) {
    final parts = languageCode.split('-');
    final hl = languageCode;    // e.g. "en-IN"
    final gl = parts.length > 1 ? parts[1] : 'US';  // e.g. "IN"
    final ceid = '$gl:${parts[0]}'; // e.g. "IN:en"

    return template
        .replaceAll('{hl}', hl)
        .replaceAll('{gl}', gl)
        .replaceAll('{ceid}', Uri.encodeComponent(ceid));
  }

  Future<List<NewsItem>> fetchByCategory(String category) async {
    final template = _categoryTopics[category];
    if (template == null) return [];
    final url = _buildUrl(template);
    return _fetch(url, category);
  }

  Future<List<NewsItem>> searchNews(String query) async {
    final parts = languageCode.split('-');
    final hl = languageCode;
    final gl = parts.length > 1 ? parts[1] : 'US';
    final ceid = '$gl:${parts[0]}';
    final url = Uri.encodeFull(
        'https://news.google.com/rss/search?q=${Uri.encodeComponent(query)}&hl=$hl&gl=$gl&ceid=${Uri.encodeComponent(ceid)}');
    return _fetch(url, 'Search');
  }

  Future<List<NewsItem>> _fetch(String url, String category) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'Mozilla/5.0 (compatible; NewsApp/1.0)'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final body = utf8.decode(response.bodyBytes);
      final document = XmlDocument.parse(body);
      final items = document.findAllElements('item');

      final List<NewsItem> result = [];
      int index = 0;

      for (final item in items) {
        final title = _text(item, 'title');
        final link = _text(item, 'link');
        final pubDate = _text(item, 'pubDate');
        final source = item.findElements('source').firstOrNull?.innerText ?? '';
        final description = _stripHtml(_text(item, 'description'));
        final imageUrl = _extractImage(item, description);
        final readableDate = _formatDate(pubDate);
        final id = '${category}_$index';

        if (title.isEmpty) continue;

        result.add(NewsItem(
          id: id,
          title: title,
          description: description,
          content: description,
          imageUrl: imageUrl.isNotEmpty
              ? imageUrl
              : 'https://picsum.photos/seed/$id/800/500',
          author: source,
          source: source,
          publishedAt: readableDate,
          category: category,
          readTime: '${(description.split(' ').length / 200).ceil() + 2} min',
          views: 0,
          articleUrl: link,
        ));
        index++;
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  String _text(XmlElement el, String tag) {
    return el.findElements(tag).firstOrNull?.innerText.trim() ?? '';
  }

  String _extractImage(XmlElement item, String description) {
    // Try <media:content url="..."/>
    for (final el in item.findAllElements('media:content')) {
      final url = el.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    // Try <enclosure url="..."/>
    for (final el in item.findAllElements('enclosure')) {
      final url = el.getAttribute('url');
      if (url != null && url.startsWith('http')) return url;
    }
    // Try img src inside description HTML
    final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
    if (imgMatch != null) return imgMatch.group(1) ?? '';
    return '';
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDate(String rfc822) {
    try {
      // RFC 822: "Mon, 07 Apr 2025 10:30:00 GMT"
      final dt = DateTime.parse(rfc822
          .replaceAllMapped(
              RegExp(r'(\w+), (\d+) (\w+) (\d+) (\d+:\d+:\d+) (.+)'),
              (m) => '${m[4]}-${_monthNum(m[3]!)}-${m[2]!.padLeft(2, '0')}T${m[5]}'))
          .toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return rfc822.length > 16 ? rfc822.substring(0, 16) : rfc822;
    }
  }

  String _monthNum(String month) {
    const months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
    };
    return months[month] ?? '01';
  }
}
