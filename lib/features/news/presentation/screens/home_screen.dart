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
    final topNewsAsync = ref.watch(newsByCategoryProvider('Top'));

    return Scaffold(
      body: topNewsAsync.when(
        loading: () => const _LoadingView(),
        error: (err, _) => _ErrorView(error: err.toString()),
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(
              child: Text(
                'No news available at the moment.',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
              ),
            );
          }
          final heroArticle = articles.first;
          final breakingNews = articles.skip(1).take(8).toList();

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: AppColors.surfaceDark,
            onRefresh: () async {
              ref.invalidate(newsByCategoryProvider('Top'));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeaturedHeroCard(
                    article: heroArticle,
                    onTap: () {
                      context.push('/article', extra: {'article': heroArticle, 'heroTag': 'featured_${heroArticle.id}'});
                    },
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Breaking News',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/discover'),
                          child: Text(
                            'More',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: breakingNews.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final article = breakingNews[index];
                        return GestureDetector(
                          onTap: () =>
                              context.push('/article', extra: {'article': article, 'heroTag': 'home_horizontal_${article.id}'}),
                          child: HorizontalNewsCard(article: article, heroTag: 'home_horizontal_${article.id}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Trends section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Trending Now',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...articles.skip(9).take(5).map((article) {
                    return _TrendingTile(article: article);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrendingTile extends StatelessWidget {
  final NewsItem article;
  const _TrendingTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article', extra: {'article': article, 'heroTag': 'trending_${article.id}'}),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.selectionDark,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.textSecondaryDark),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${article.source}  •  ${article.publishedAt}',
                    style: const TextStyle(
                        color: AppColors.textSecondaryDark, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right,
                size: 16, color: AppColors.textSecondaryDark),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          SizedBox(height: 16),
          Text('Loading today\'s news...',
              style: TextStyle(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.wifi_slash,
                color: AppColors.textSecondaryDark, size: 48),
            const SizedBox(height: 16),
            const Text('Could not load news',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Check your internet connection',
                style: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
