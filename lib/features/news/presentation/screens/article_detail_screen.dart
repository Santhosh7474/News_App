import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/news_item.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // Hero image — top 60%
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.6,
              child: Hero(
                tag: heroTag,
                child: SizedBox(
                  width: size.width,
                  height: size.height * 0.6,
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Gradient fade over image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.6,
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 0.8, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Back button — glass pill
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(CupertinoIcons.back,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Overlay text on image: category + title + subtitle
            Positioned(
              bottom: size.height * 0.42,
              left: 0,
              right: 0,
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glass category pill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            article.category.isNotEmpty ? article.category : "News",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.5,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom glass sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size.height * 0.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: size.width,   // <--- STRICT WIDTH
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.72),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.80),
                          width: 1,
                        ),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.90),
                                Colors.white.withValues(alpha: 0.55),
                              ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 14),
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),

                        // Author / date pills row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: _buildGlassPill(
                                  context: context,
                                  isDark: isDark,
                                  icon: CupertinoIcons.person_solid,
                                  text: article.author.isNotEmpty ? article.author : 'Unknown',
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                flex: 1,
                                child: _buildGlassPill(
                                  context: context,
                                  isDark: isDark,
                                  icon: CupertinoIcons.calendar,
                                  text: article.publishedAt.isNotEmpty ? article.publishedAt : 'Recent',
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Article content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      article.title,
                                      style: TextStyle(
                                        color: primaryTextColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        height: 1.35,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      article.content.isNotEmpty
                                          ? article.content
                                          : article.description,
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 16,
                                        height: 1.6,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassPill({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String text,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.45),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.65),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: secondaryTextColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
