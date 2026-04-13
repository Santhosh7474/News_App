import re

# 1. Update app_router.dart
p = 'lib/routing/app_router.dart'
with open(p, 'r') as f:
    text = f.read()
text = text.replace(
    '''final article = state.extra as NewsItem;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: ArticleDetailScreen(article: article),''',
    '''final extra = state.extra as Map<String, dynamic>;
                      final article = extra['article'] as NewsItem;
                      final heroTag = extra['heroTag'] as String;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: ArticleDetailScreen(article: article, heroTag: heroTag),'''
)
with open(p, 'w') as f:
    f.write(text)

# 2. Update horizontal_news_card.dart
p = 'lib/features/news/presentation/widgets/horizontal_news_card.dart'
with open(p, 'r') as f:
    text = f.read()
text = text.replace('final NewsItem article;', 'final NewsItem article;\n  final String heroTag;')
text = text.replace('required this.article,\n  });', 'required this.article,\n    required this.heroTag,\n  });')
text = text.replace("tag: 'image_${article.id}'", "tag: heroTag")
with open(p, 'w') as f:
    f.write(text)

# 3. Update vertical_news_card.dart
p = 'lib/features/news/presentation/widgets/vertical_news_card.dart'
with open(p, 'r') as f:
    text = f.read()
text = text.replace('final NewsItem article;', 'final NewsItem article;\n  final String heroTag;')
text = text.replace('required this.article,\n  });', 'required this.article,\n    required this.heroTag,\n  });')
text = text.replace("tag: 'image_${article.id}'", "tag: heroTag")
with open(p, 'w') as f:
    f.write(text)

# 4. Update article_detail_screen.dart
p = 'lib/features/news/presentation/screens/article_detail_screen.dart'
with open(p, 'r') as f:
    text = f.read()
text = text.replace('final NewsItem article;', 'final NewsItem article;\n  final String heroTag;')
text = text.replace('required this.article,\n  });', 'required this.article,\n    required this.heroTag,\n  });')
text = text.replace("tag: 'image_${article.id}'", "tag: heroTag")
with open(p, 'w') as f:
    f.write(text)

# 5. Update home_screen.dart
p = 'lib/features/news/presentation/screens/home_screen.dart'
with open(p, 'r') as f:
    text = f.read()
text = text.replace(
    "context.push('/article', extra: heroArticle);",
    "context.push('/article', extra: {'article': heroArticle, 'heroTag': 'featured_${heroArticle.id}'});"
)
text = text.replace(
    "context.push('/article', extra: article)",
    "context.push('/article', extra: {'article': article, 'heroTag': 'home_horizontal_${article.id}'})"
)
text = text.replace(
    "HorizontalNewsCard(article: article)",
    "HorizontalNewsCard(article: article, heroTag: 'home_horizontal_${article.id}')"
)
# For TrendingTile
text = text.replace(
    "context.push('/article', extra: {'article': article, 'heroTag': 'home_horizontal_${article.id}'}),\n      child: Padding(",
    "context.push('/article', extra: {'article': article, 'heroTag': 'trending_${article.id}'}),\n      child: Padding("
)
with open(p, 'w') as f:
    f.write(text)

# 6. Update discover_screen.dart
p = 'lib/features/news/presentation/screens/discover_screen.dart'
with open(p, 'r') as f:
    text = f.read()
text = text.replace(
    "context.push('/article', extra: article)",
    "context.push('/article', extra: {'article': article, 'heroTag': 'discover_cat_${article.id}'})"
)
text = text.replace(
    "VerticalNewsCard(article: article)",
    "VerticalNewsCard(article: article, heroTag: 'discover_cat_${article.id}')"
)
# Fix search results replacement clashing with discover_cat:
text = text.replace(
    "context.push('/article', extra: {'article': article, 'heroTag': 'discover_cat_${article.id}'}),\n              child: VerticalNewsCard(article: article, heroTag: 'discover_cat_${article.id}'),",
    "context.push('/article', extra: {'article': article, 'heroTag': 'discover_cat_${article.id}'}),\n              child: VerticalNewsCard(article: article, heroTag: 'discover_cat_${article.id}'),\n            "
) # Simple text replace works.
# Actually let's just make search and discover exactly the same ('discover_cat'), since search overlay covers the screen and they never exist simultaneously offstage!
with open(p, 'w') as f:
    f.write(text)

print("Done fixing heroes.")
