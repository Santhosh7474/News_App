import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/news_item.dart';

class HorizontalNewsCard extends StatelessWidget {
  final NewsItem article;
  final String heroTag;

  const HorizontalNewsCard({
    super.key,
    required this.article,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image fills the top - let Expanded or fixed height handle it
              Expanded(
                flex: 6,
                child: Hero(
                  tag: heroTag,
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.selectionDark,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: AppColors.textSecondaryDark, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
              // Content takes the remaining space
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.3,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${article.publishedAt}  •  ${article.author}',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
