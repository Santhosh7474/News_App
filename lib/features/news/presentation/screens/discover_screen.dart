import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/news/data/rss_service.dart';
import '../../../../providers/news_provider.dart';
import '../widgets/vertical_news_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = RssService.categoryFeeds.keys.toList();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    setState(() => _isSearching = query.isNotEmpty);
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).updateQuery(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearching = false);
    ref.read(searchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final selectionColor = isDark ? AppColors.selectionDark : AppColors.selectionLight;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.bars,
                          size: 28, color: Colors.white),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Discover',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'News from all over the World',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: selectionColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.search,
                            color: secondaryColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search any topic...',
                              hintStyle: TextStyle(color: secondaryColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_isSearching)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Icon(CupertinoIcons.xmark_circle_fill,
                                color: secondaryColor, size: 20),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category tabs — hidden when searching
                  if (!_isSearching)
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: isDark ? Colors.white : Colors.black,
                      indicatorWeight: 2.5,
                      labelColor: isDark ? Colors.white : Colors.black,
                      unselectedLabelColor: secondaryColor,
                      labelStyle: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      dividerColor: Colors.transparent,
                      tabs: categories
                          .map((cat) => Tab(text: cat))
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: _isSearching
                  ? const _SearchResults()
                  : TabBarView(
                      controller: _tabController,
                      children: categories.map((category) {
                        return _CategoryNewsList(category: category);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryNewsList extends ConsumerWidget {
  final String category;
  const _CategoryNewsList({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsByCategoryProvider(category));

    return newsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.wifi_slash,
                color: AppColors.textSecondaryDark, size: 40),
            const SizedBox(height: 12),
            const Text('Could not load news',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      data: (articles) => RefreshIndicator(
        color: Colors.white,
        backgroundColor: AppColors.surfaceDark,
        onRefresh: () async =>
            ref.invalidate(newsByCategoryProvider(category)),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () => context.push('/article',
                  extra: {'article': article, 'heroTag': 'discover_cat_${article.id}'}),
              child: VerticalNewsCard(
                  article: article,
                  heroTag: 'discover_cat_${article.id}'),
            );
          },
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          SizedBox(height: 16),
          Text('Searching...',
              style: TextStyle(color: AppColors.textSecondaryDark)),
        ],
      )),
      error: (err, stack) => const Center(
          child: Text('Search failed. Try again.',
              style: TextStyle(color: AppColors.textSecondaryDark))),
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.search,
                    color: AppColors.textSecondaryDark, size: 48),
                SizedBox(height: 16),
                Text('No results found',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Try a different search term',
                    style:
                        TextStyle(color: AppColors.textSecondaryDark)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () => context.push('/article',
                  extra: {'article': article, 'heroTag': 'search_${article.id}'}),
              child: VerticalNewsCard(
                  article: article, heroTag: 'search_${article.id}'),
            );
          },
        );
      },
    );
  }
}
