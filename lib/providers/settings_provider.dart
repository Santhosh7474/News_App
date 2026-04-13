import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Keys ────────────────────────────────────────────────────────────────────
const _kThemeKey    = 'app_theme_mode';
const _kLangKey     = 'app_language';
const _kLangSetKey  = 'language_selected'; // true once the user has chosen

// ─── Supported Languages ─────────────────────────────────────────────────────
class AppLanguage {
  final String code;      // BCP-47 e.g. "en-IN"
  final String name;      // Display name in that language
  final String flag;      // emoji flag
  const AppLanguage({required this.code, required this.name, required this.flag});
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(code: 'en-IN', name: 'English',       flag: '🇮🇳'),
  AppLanguage(code: 'hi-IN', name: 'हिंदी',           flag: '🇮🇳'),
  AppLanguage(code: 'ta-IN', name: 'தமிழ்',           flag: '🇮🇳'),
  AppLanguage(code: 'te-IN', name: 'తెలుగు',          flag: '🇮🇳'),
  AppLanguage(code: 'kn-IN', name: 'ಕನ್ನಡ',           flag: '🇮🇳'),
  AppLanguage(code: 'ml-IN', name: 'മലയാളം',          flag: '🇮🇳'),
  AppLanguage(code: 'mr-IN', name: 'मराठी',           flag: '🇮🇳'),
  AppLanguage(code: 'bn-BD', name: 'বাংলা',            flag: '🇧🇩'),
  AppLanguage(code: 'en-US', name: 'English (US)',   flag: '🇺🇸'),
  AppLanguage(code: 'en-GB', name: 'English (UK)',   flag: '🇬🇧'),
  AppLanguage(code: 'fr-FR', name: 'Français',       flag: '🇫🇷'),
  AppLanguage(code: 'de-DE', name: 'Deutsch',        flag: '🇩🇪'),
  AppLanguage(code: 'es-ES', name: 'Español',        flag: '🇪🇸'),
  AppLanguage(code: 'pt-BR', name: 'Português',      flag: '🇧🇷'),
  AppLanguage(code: 'ja-JP', name: '日本語',           flag: '🇯🇵'),
  AppLanguage(code: 'ko-KR', name: '한국어',            flag: '🇰🇷'),
  AppLanguage(code: 'zh-CN', name: '中文(简体)',        flag: '🇨🇳'),
  AppLanguage(code: 'ar-SA', name: 'العربية',         flag: '🇸🇦'),
];

// ─── Settings State ───────────────────────────────────────────────────────────
class AppSettings {
  final ThemeMode themeMode;
  final String languageCode;
  final bool languageSelected;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.languageCode = 'en-IN',
    this.languageSelected = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? languageSelected,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      languageSelected: languageSelected ?? this.languageSelected,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();

    final themeIndex = _prefs.getInt(_kThemeKey) ?? ThemeMode.dark.index;
    final lang = _prefs.getString(_kLangKey) ?? 'en-IN';
    final langSet = _prefs.getBool(_kLangSetKey) ?? false;

    return AppSettings(
      themeMode: ThemeMode.values[themeIndex],
      languageCode: lang,
      languageSelected: langSet,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setInt(_kThemeKey, mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setString(_kLangKey, code);
    await _prefs.setBool(_kLangSetKey, true);
    state = AsyncData(state.value!.copyWith(languageCode: code, languageSelected: true));
  }

  /// Mark language as selected without changing it (for existing users)
  Future<void> markLanguageSelected() async {
    await _prefs.setBool(_kLangSetKey, true);
    state = AsyncData(state.value!.copyWith(languageSelected: true));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ─── Convenience Providers ────────────────────────────────────────────────────
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.dark;
});

final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).value?.languageCode ?? 'en-IN';
});

final languageSelectedProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).value?.languageSelected ?? false;
});

final currentLanguageProvider = Provider<AppLanguage>((ref) {
  final code = ref.watch(languageCodeProvider);
  return kSupportedLanguages.firstWhere(
    (l) => l.code == code,
    orElse: () => kSupportedLanguages.first,
  );
});
