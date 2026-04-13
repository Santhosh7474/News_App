import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/news_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../ui/widgets/glass_container.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go('/login');
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('App Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).setTheme(ThemeMode.light);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (current == ThemeMode.light)
                  const Icon(CupertinoIcons.checkmark, size: 16),
                const SizedBox(width: 8),
                const Text('Light'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).setTheme(ThemeMode.dark);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (current == ThemeMode.dark)
                  const Icon(CupertinoIcons.checkmark, size: 16),
                const SizedBox(width: 8),
                const Text('Dark'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).setTheme(ThemeMode.system);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (current == ThemeMode.system)
                  const Icon(CupertinoIcons.checkmark, size: 16),
                const SizedBox(width: 8),
                const Text('System Default'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentCode = ref.read(languageCodeProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LanguagePickerSheet(
        currentCode: currentCode,
        onSelect: (code) async {
          await ref.read(settingsProvider.notifier).setLanguage(code);
          // Invalidate all category & search caches so news reloads in new language
          ref.invalidate(newsByCategoryProvider);
          ref.invalidate(searchResultsProvider);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user          = ref.watch(currentUserProvider);
    final themeMode     = ref.watch(themeModeProvider);
    final currentLang   = ref.watch(currentLanguageProvider);
    final isDark        = Theme.of(context).brightness == Brightness.dark;

    String themeLabel;
    switch (themeMode) {
      case ThemeMode.light:  themeLabel = 'Light';          break;
      case ThemeMode.dark:   themeLabel = 'Dark';           break;
      case ThemeMode.system: themeLabel = 'System';         break;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(letterSpacing: -1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Avatar
              Hero(
                tag: 'user_avatar',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: user?.photoURL != null
                        ? CachedNetworkImage(
                            imageUrl: user!.photoURL!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                            errorWidget: (context, url, error) => const Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white,
                                size: 50),
                          )
                        : Icon(CupertinoIcons.person_fill,
                            color: isDark ? Colors.white : Colors.black54,
                            size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'User',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
              const SizedBox(height: 48),

              // ── Preferences ─────────────────────────────────────────────────
              _SectionHeader('Preferences'),

              _SettingsTile(
                icon: CupertinoIcons.moon_stars,
                label: 'App Theme',
                value: themeLabel,
                onTap: () => _showThemePicker(context, ref),
              ),

              _SettingsTile(
                icon: CupertinoIcons.globe,
                label: 'News Language',
                value: '${currentLang.flag}  ${currentLang.name}',
                onTap: () => _showLanguagePicker(context, ref),
              ),

              _SettingsTile(
                icon: CupertinoIcons.bell,
                label: 'Notifications',
                trailing: CupertinoSwitch(
                  value: true,
                  onChanged: (_) {},
                  activeTrackColor: isDark ? Colors.white : Colors.black,
                  inactiveTrackColor: isDark
                      ? AppColors.selectionDark
                      : AppColors.selectionLight,
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader('About'),
              _SettingsTile(
                icon: CupertinoIcons.info_circle,
                label: 'App Version',
                value: '1.0.0',
              ),
              _SettingsTile(
                icon: CupertinoIcons.doc_text,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _SettingsTile(
                icon: CupertinoIcons.doc_plaintext,
                label: 'Terms of Service',
                onTap: () {},
              ),

              const SizedBox(height: 32),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: () => _signOut(context, ref),
                  child: GlassContainer(
                    height: 56,
                    width: double.infinity,
                    borderRadius: 16,
                    color: Colors.red.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.square_arrow_left,
                            color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }
}

// ── Bottom Sheet for Language Picker ──────────────────────────────────────────
class _LanguagePickerSheet extends StatefulWidget {
  final String currentCode;
  final ValueChanged<String> onSelect;

  const _LanguagePickerSheet({
    required this.currentCode,
    required this.onSelect,
  });

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text('News Language',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: kSupportedLanguages.length,
              itemBuilder: (context, i) {
                final lang     = kSupportedLanguages[i];
                final isSel    = _selected == lang.code;
                return GestureDetector(
                  onTap: () => setState(() => _selected = lang.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.06))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel
                            ? (isDark ? Colors.white38 : Colors.black26)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(lang.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                        ),
                        if (isSel)
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: isDark ? Colors.white : Colors.black,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: GestureDetector(
              onTap: () => widget.onSelect(_selected),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isDark ? Colors.white : Colors.black87, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (value != null)
              Text(value!, style: Theme.of(context).textTheme.bodyMedium),
            ?trailing,
            if (onTap != null && trailing == null)
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }
}
