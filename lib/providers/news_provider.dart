import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/news/data/rss_service.dart';
import '../models/news_item.dart';
import 'settings_provider.dart';

// RssService is rebuilt whenever the language changes
final rssServiceProvider = Provider<RssService>((ref) {
  final lang = ref.watch(languageCodeProvider);
  return RssService(languageCode: lang);
});

// Fetches news by category — auto-cached by Riverpod per category string
final newsByCategoryProvider =
    FutureProvider.family<List<NewsItem>, String>((ref, category) async {
  final service = ref.watch(rssServiceProvider);
  return service.fetchByCategory(category);
});

// Search query state — simple Notifier in Riverpod 3.x
class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

// Search results — reacts to query changes
final searchResultsProvider = FutureProvider<List<NewsItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final service = ref.watch(rssServiceProvider);
  return service.searchNews(query);
});
