import 'dart:async';
import 'dart:ui';

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
    final gradColors =
        isDark ? AppColors.getDarkBgGradient() : AppColors.getLightBgGradient();
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient bg
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Orbs
          Positioned(
            top: -120,
            right: -80,
            child: _Orb(
              size: 300,
              color: isDark
                  ? const Color(0x252A1070)
                  : const Color(0x38AACCFF),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: _Orb(
              size: 240,
              color: isDark
                  ? const Color(0x200A3060)
                  : const Color(0x30CCE8FF),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Icon(CupertinoIcons.bars,
                              size: 26, color: primaryTextColor),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Discover',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'News from all over the World',
                        style: TextStyle(
                            color: secondaryColor, fontSize: 14),
                      ),
                      const SizedBox(height: 18),

                      // Liquid glass search bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        Colors.white.withValues(alpha: 0.12),
                                        Colors.white.withValues(alpha: 0.04),
                                      ]
                                    : [
                                        Colors.white.withValues(alpha: 0.80),
                                        Colors.white.withValues(alpha: 0.45),
                                      ],
                              ),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.65),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.search,
                                    color: secondaryColor, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(
                                        color: primaryTextColor, fontSize: 15),
                                    onChanged: _onSearchChanged,
                                    decoration: InputDecoration(
                                      hintText: 'Search any topic...',
                                      hintStyle: TextStyle(
                                          color: secondaryColor, fontSize: 15),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (_isSearching)
                                  GestureDetector(
                                    onTap: _clearSearch,
                                    child: Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                        color: secondaryColor,
                                        size: 18),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // CupertinoSegmentedControl-style liquid glass tabs
                      if (!_isSearching)
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: primaryTextColor,
                          indicatorWeight: 2,
                          labelColor: primaryTextColor,
                          unselectedLabelColor: secondaryColor,
                          labelStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          unselectedLabelStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          dividerColor: Colors.transparent,
                          tabs: categories.map((cat) => Tab(text: cat)).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return newsAsync.when(
      loading: () => Center(
          child: CircularProgressIndicator(
              color: primaryTextColor, strokeWidth: 2)),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.wifi_slash,
                color: secondaryTextColor, size: 40),
            const SizedBox(height: 12),
            Text('Could not load news',
                style: TextStyle(color: primaryTextColor, fontSize: 16)),
          ],
        ),
      ),
      data: (articles) => RefreshIndicator(
        color: primaryTextColor,
        backgroundColor: surfaceColor,
        onRefresh: () async =>
            ref.invalidate(newsByCategoryProvider(category)),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () => context.push('/article',
                  extra: {
                    'article': article,
                    'heroTag': 'discover_cat_${article.id}'
                  }),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return resultsAsync.when(
      loading: () => Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: primaryTextColor, strokeWidth: 2),
          const SizedBox(height: 16),
          Text('Searching...',
              style: TextStyle(color: secondaryTextColor)),
        ],
      )),
      error: (err, stack) => Center(
          child: Text('Search failed. Try again.',
              style: TextStyle(color: secondaryTextColor))),
      data: (articles) {
        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.search,
                    color: secondaryTextColor, size: 48),
                const SizedBox(height: 16),
                Text('No results found',
                    style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Try a different search term',
                    style: TextStyle(color: secondaryTextColor)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () => context.push('/article',
                  extra: {
                    'article': article,
                    'heroTag': 'search_${article.id}'
                  }),
              child: VerticalNewsCard(
                  article: article, heroTag: 'search_${article.id}'),
            );
          },
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
