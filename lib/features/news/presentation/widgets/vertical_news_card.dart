import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/news_item.dart';

class VerticalNewsCard extends StatelessWidget {
  final NewsItem article;
  final String heroTag;

  const VerticalNewsCard({
    super.key,
    required this.article,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Image
        Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: article.imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    article.publishedAt,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'By ${article.author}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
