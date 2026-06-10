import 'package:flutter/material.dart';

class UiStateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('uk');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Перемикання теми інтерфейсу
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Зміна мови додатка
  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Простий локалізатор для швидкого доступу до перекладів без нативних плагінів
  String translate(String key) {
    final Map<String, Map<String, String>> localizedValues = {
      'uk': {
        'app_title': 'ReHab Професіонал',
        'login_title': 'Вхід у систему',
        'select_user': 'Оберіть профіль спеціаліста',
        'username': 'Логін / Ініціали',
        'password': 'Пароль доступу',
        'enter': 'Увійти',
        'register': 'Зареєструвати лікаря',
        'bio_auth': 'Біометричний вхід',
        'full_name': 'ПІБ Лікаря (для підпису)',
        'required_field': 'Обов\'язкове поле',
      },
      'en': {
        'app_title': 'ReHab Professional',
        'login_title': 'System Authentication',
        'select_user': 'Select Specialist Profile',
        'username': 'Username / Initials',
        'password': 'Security Password',
        'enter': 'Sign In',
        'register': 'Register Medical Practitioner',
        'bio_auth': 'Biometric Authentication',
        'full_name': 'Doctor\'s Full Name (for signature)',
        'required_field': 'Required field',
      }
    };
    return localizedValues[_locale.languageCode]?[key] ?? key;
  }
}
