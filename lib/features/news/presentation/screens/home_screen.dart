import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/news_item.dart';
import '../../../../providers/news_provider.dart';
import '../widgets/featured_hero_card.dart';
import '../widgets/horizontal_news_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradColors =
        isDark ? AppColors.getDarkBgGradient() : AppColors.getLightBgGradient();
    final topNewsAsync = ref.watch(newsByCategoryProvider('Top'));
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Ambient orbs
          Positioned(
            top: -100,
            right: -80,
            child: _Orb(
              size: 320,
              color: isDark
                  ? const Color(0x2A2A1070)
                  : const Color(0x40AACCFF),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: _Orb(
              size: 260,
              color: isDark
                  ? const Color(0x220A3060)
                  : const Color(0x35CCE8FF),
            ),
          ),
          // Content
          topNewsAsync.when(
            loading: () => _LoadingView(isDark: isDark),
            error: (err, _) => _ErrorView(error: err.toString(), isDark: isDark),
            data: (articles) {
              if (articles.isEmpty) {
                return Center(
                  child: Text('No news available at the moment.',
                      style: TextStyle(color: secondaryTextColor, fontSize: 16)),
                );
              }
              final heroArticle = articles.first;
              final breakingNews = articles.skip(1).take(8).toList();

              return RefreshIndicator(
                color: primaryTextColor,
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                onRefresh: () async =>
                    ref.invalidate(newsByCategoryProvider('Top')),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FeaturedHeroCard(
                        article: heroArticle,
                        onTap: () => context.push('/article', extra: {
                          'article': heroArticle,
                          'heroTag': 'featured_${heroArticle.id}'
                        }),
                      ),
                      const SizedBox(height: 28),

                      // Section header row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Breaking News',
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/discover'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.10)
                                          : Colors.white.withValues(alpha: 0.60),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.15)
                                            : Colors.white.withValues(alpha: 0.70),
                                      ),
                                    ),
                                    child: Text(
                                      'More',
                                      style: TextStyle(
                                        color: primaryTextColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Horizontal cards
                      SizedBox(
                        height: 228,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: breakingNews.length,
                          separatorBuilder: (_, idx) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final article = breakingNews[index];
                            return GestureDetector(
                              onTap: () => context.push('/article', extra: {
                                'article': article,
                                'heroTag': 'home_horizontal_${article.id}'
                              }),
                              child: HorizontalNewsCard(
                                  article: article,
                                  heroTag: 'home_horizontal_${article.id}'),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Trending Now',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...articles.skip(9).take(5).map((article) {
                        return _TrendingTile(
                          article: article,
                          isDark: isDark,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrendingTile extends StatelessWidget {
  final NewsItem article;
  final bool isDark;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _TrendingTile({
    required this.article,
    required this.isDark,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article',
          extra: {'article': article, 'heroTag': 'trending_${article.id}'}),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.09),
                          Colors.white.withValues(alpha: 0.03),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.40),
                        ],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.60),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      article.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: isDark
                            ? AppColors.selectionDark
                            : AppColors.selectionLight,
                        child: Icon(Icons.image_not_supported,
                            color: secondaryTextColor, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.3,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${article.source}  •  ${article.publishedAt}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(CupertinoIcons.chevron_right,
                      size: 14, color: secondaryTextColor),
                ],
              ),
            ),
          ),
        ),
      ),
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

class _LoadingView extends StatelessWidget {
  final bool isDark;
  const _LoadingView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading today\'s news...',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final bool isDark;
  const _ErrorView({required this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.wifi_slash,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                size: 48),
            const SizedBox(height: 16),
            Text('Could not load news',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Check your internet connection',
                style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                        : AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}
