import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/news_item.dart';
import '../../../../ui/widgets/glass_container.dart';

class ArticleDetailScreen extends StatelessWidget {
  final NewsItem article;
  final String heroTag;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Hero(
              tag: heroTag,
              child: Image(
                image: CachedNetworkImageProvider(article.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Image Darkener for Text
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          // Top Header Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(CupertinoIcons.back, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    borderRadius: 24,
                    child: Text(
                      article.category,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.description.isEmpty ? 'A new study indicates that the condition might be less of a worry than once believed.' : article.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1), // space for bottom sheet
                ],
              ),
            ),
          ),

          // Bottom Content Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pill Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatPill(
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.person_solid, size: 16, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(article.author, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      _StatPill(
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.calendar, size: 16, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(article.publishedAt, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        article.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryDark,
                              height: 1.6,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final Widget child;

  const _StatPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA), // Light grey pills
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}
