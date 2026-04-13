import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/news_provider.dart';
import '../../../../providers/settings_provider.dart';

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
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (current == ThemeMode.light)
                const Icon(CupertinoIcons.checkmark, size: 16),
              const SizedBox(width: 8),
              const Text('Light'),
            ]),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).setTheme(ThemeMode.dark);
              Navigator.pop(ctx);
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (current == ThemeMode.dark)
                const Icon(CupertinoIcons.checkmark, size: 16),
              const SizedBox(width: 8),
              const Text('Dark'),
            ]),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).setTheme(ThemeMode.system);
              Navigator.pop(ctx);
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (current == ThemeMode.system)
                const Icon(CupertinoIcons.checkmark, size: 16),
              const SizedBox(width: 8),
              const Text('System Default'),
            ]),
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
          ref.invalidate(newsByCategoryProvider);
          ref.invalidate(searchResultsProvider);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLang = ref.watch(currentLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifsOn = ref.watch(notificationsEnabledProvider);
    final gradColors =
        isDark ? AppColors.getDarkBgGradient() : AppColors.getLightBgGradient();
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    String themeLabel;
    switch (themeMode) {
      case ThemeMode.light:
        themeLabel = 'Light';
        break;
      case ThemeMode.dark:
        themeLabel = 'Dark';
        break;
      case ThemeMode.system:
        themeLabel = 'System';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Orbs
          Positioned(
            top: -100,
            right: -80,
            child: _Orb(
              size: 300,
              color: isDark
                  ? const Color(0x252A1070)
                  : const Color(0x38AACCFF),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: _Orb(
              size: 220,
              color: isDark
                  ? const Color(0x1A0A3060)
                  : const Color(0x28CCE8FF),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Avatar — glass ring
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.12),
                                    Colors.white.withValues(alpha: 0.03),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.85),
                                    Colors.white.withValues(alpha: 0.40),
                                  ],
                          ),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.75),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: isDark ? 0.35 : 0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user?.photoURL != null
                              ? CachedNetworkImage(
                                  imageUrl: user!.photoURL!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Icon(
                                    CupertinoIcons.person_fill,
                                    color: primaryTextColor,
                                    size: 50,
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    CupertinoIcons.person_fill,
                                    color: primaryTextColor,
                                    size: 50,
                                  ),
                                )
                              : Icon(CupertinoIcons.person_fill,
                                  color: primaryTextColor, size: 50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style:
                        TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 36),

                  // ── Preferences ──────────────────────────────────────────────
                  _SectionHeader(
                      'Preferences',
                      primaryTextColor: secondaryTextColor),
                  _GlassTile(
                    icon: CupertinoIcons.moon_stars,
                    label: 'App Theme',
                    value: themeLabel,
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => _showThemePicker(context, ref),
                  ),
                  _GlassTile(
                    icon: CupertinoIcons.globe,
                    label: 'News Language',
                    value: '${currentLang.flag}  ${currentLang.name}',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => _showLanguagePicker(context, ref),
                  ),
                  _GlassTile(
                    icon: CupertinoIcons.bell,
                    label: 'Notifications',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    trailing: CupertinoSwitch(
                      value: notifsOn,
                      onChanged: (_) => ref
                          .read(settingsProvider.notifier)
                          .toggleNotifications(),
                      activeTrackColor: isDark
                          ? Colors.white.withValues(alpha: 0.85)
                          : Colors.black.withValues(alpha: 0.75),
                      inactiveTrackColor: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.09),
                    ),
                  ),

                  const SizedBox(height: 8),
                  _SectionHeader('About',
                      primaryTextColor: secondaryTextColor),
                  _GlassTile(
                    icon: CupertinoIcons.info_circle,
                    label: 'App Version',
                    value: '1.0.0',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  _GlassTile(
                    icon: CupertinoIcons.doc_text,
                    label: 'Privacy Policy',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      context.push('/legal', extra: {
                        'title': 'Privacy Policy',
                        'content':
                            'We care deeply about your privacy and data security.\n\n1. Information We Collect\nWe collect information you provide directly to us, such as when you create or modify your account, request support, or otherwise communicate with us. The types of information we may collect include your name, email address, profile information, and any other information you choose to provide.\n\nWe also collect information about your use of the app, including your reading history, search queries, preferences, and in-app behaviors. This helps us personalize your news feed.\n\n2. How We Use Your Information\nWe use the information we collect to:\n- Provide, maintain, and improve our services\n- Personalize your news experience\n- Send you technical notices and support messages\n- Respond to your comments and questions\n- Monitor and analyze trends and usage\n\n3. Sharing of Information\nWe do not share your personal information with third parties except as described in this policy. We may share information with vendors and service providers that perform services on our behalf.\n\n4. Data Retention\nWe retain personal information for as long as necessary to provide the Services and fulfill the purposes outlined in this Privacy Policy.\n\n5. Security\nWe take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction.\n\n6. Changes to this Policy\nWe may change this privacy policy from time to time. If we make changes, we will notify you by revising the date at the top of the policy.',
                      });
                    },
                  ),
                  _GlassTile(
                    icon: CupertinoIcons.doc_plaintext,
                    label: 'Terms of Service',
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      context.push('/legal', extra: {
                        'title': 'Terms of Service',
                        'content':
                            'By accessing or using the News App, you agree to be bound by these Terms of Service.\n\n1. Acceptance of Terms\nBy accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.\n\n2. Content and Conduct\nYou are responsible for your use of the Services and for any Content you provide, including compliance with applicable laws, rules, and regulations. You should only provide Content that you are comfortable sharing with others.\n\n3. Proprietary Rights\nAll rights, title, and interest in and to the Services (excluding Content provided by users) are and will remain the exclusive property of News App and its licensors. The Services are protected by copyright, trademark, and other laws.\n\n4. Privacy\nAny information that you provide to News App is subject to our Privacy Policy, which governs our collection and use of your information.\n\n5. Termination\nWe may suspend or terminate your accounts or cease providing you with all or part of the Services at any time for any reason, including, but not limited to, if we reasonably believe:\n- You have violated these Terms\n- You create risk or possible legal exposure for us\n- Our provision of the Services is no longer commercially viable\n\n6. Disclaimers and Limitations of Liability\nPlease read this section carefully since it limits the liability of News App and its parents, subsidiaries, affiliates, related companies, officers, directors, employees, agents, representatives, partners, and licensors (collectively, the "News App Entities").\n\n7. Governing Law\nThese Terms shall be governed by the laws of the jurisdiction in which the company is established, without respect to its conflict of laws principles.\n\n8. Changes to Terms\nWe may revise these Terms from time to time. The most current version will always be on this page.',
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Sign out — liquid glass danger button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: () => _signOut(context, ref),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.red.withValues(alpha: 0.25),
                                  Colors.red.withValues(alpha: 0.10),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.35),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
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
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// ── Language Picker Sheet ─────────────────────────────────────────────────────
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
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.12),
                      const Color(0xFF0A0A14).withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.92),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            border: const Border(
              top: BorderSide(color: Color(0x30FFFFFF), width: 1),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('News Language',
                        style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: kSupportedLanguages.length,
                  itemBuilder: (context, i) {
                    final lang = kSupportedLanguages[i];
                    final isSel = _selected == lang.code;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = lang.code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSel
                              ? (isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.70))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel
                                ? (isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.80))
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
                                  style: TextStyle(
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15)),
                            ),
                            if (isSel)
                              Icon(CupertinoIcons.checkmark_circle_fill,
                                  color: primaryTextColor, size: 20),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.22),
                                    Colors.white.withValues(alpha: 0.10),
                                  ]
                                : [
                                    Colors.black.withValues(alpha: 0.82),
                                    Colors.black.withValues(alpha: 0.68),
                                  ],
                          ),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.black.withValues(alpha: 0.20),
                            width: 1,
                          ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primaryTextColor;
  const _SectionHeader(this.title, {required this.primaryTextColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: primaryTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _GlassTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _GlassTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.03),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.80),
                          Colors.white.withValues(alpha: 0.45),
                        ],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.65),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: isDark ? 0.20 : 0.06),
                    blurRadius: 12,
                    spreadRadius: -2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: primaryTextColor, size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ),
                  if (value != null)
                    Text(value!,
                        style: TextStyle(
                            color: secondaryTextColor, fontSize: 14)),
                  ?trailing,
                  if (onTap != null && trailing == null)
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
