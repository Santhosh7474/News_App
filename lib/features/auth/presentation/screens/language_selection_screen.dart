import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/settings_provider.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;
  bool _isSaving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    // Pre-select current language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selected = ref.read(languageCodeProvider);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    setState(() => _isSaving = true);
    await ref.read(settingsProvider.notifier).setLanguage(_selected!);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.globe,
                          color: isDark ? Colors.black : Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Choose your\nNews Language',
                        style: theme.textTheme.displayMedium?.copyWith(
                          letterSpacing: -1,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select the language you\'d like to read news in.\nYou can change this anytime in Settings.',
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kSupportedLanguages.length,
                    itemBuilder: (context, i) {
                      final lang = kSupportedLanguages[i];
                      final isSelected = _selected == lang.code;
                      return _LanguageTile(
                        language: lang,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selected = lang.code),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: GestureDetector(
                    onTap: _selected == null || _isSaving ? null : _confirm,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selected != null
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark
                                ? AppColors.selectionDark
                                : AppColors.selectionLight),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: _isSaving
                            ? CircularProgressIndicator(
                                color: isDark ? Colors.black : Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.07))
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white54 : Colors.black38)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    language.code,
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
