import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../models/news_item.dart';
import '../../../../ui/widgets/glass_container.dart';

class FeaturedHeroCard extends StatelessWidget {
  final NewsItem article;
  final VoidCallback onTap;

  const FeaturedHeroCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          image: DecorationImage(
            image: CachedNetworkImageProvider(article.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      borderRadius: 20,
                      child: Text(
                        'News of the day',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Learn More',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_right,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
