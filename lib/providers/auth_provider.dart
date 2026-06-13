import 'package:flutter/material.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Інстанс твоєї бази даних Drift
  bool _isAuthenticated = false;
  bool _isBiometricsEnabled = true; // Вмикаємо біометрію за дефолтом
  List<dynamic> _savedUsers = [];  // Список збережених користувачів для випадаючого списку

  AuthProvider(this._db) {
    _loadSavedUsers(); // Автоматично завантажуємо користувачів при старті
  }

  // ГЕТТЕРИ, які вимагає твій login_screen.dart
  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  List<dynamic> get savedUsers => _savedUsers;

  // Асинхронне завантаження користувачів з бази даних
  Future<void> _loadSavedUsers() async {
    try {
      // Витягуємо користувачів з таблиці через Drift
      _savedUsers = await _db.select(_db.users).get();
      notifyListeners();
    } catch (e) {
      debugPrint("Не вдалося завантажити збережених користувачів: $e");
    }
  }

  // 1. ВХІД ЗА БІОМЕТРІЄЮ (2 позиційні аргументи, як у твоєму логін-екрані)
  Future<bool> loginWithBiometrics(String username, RehabProvider rehabProvider) async {
    try {
      final query = _db.select(_db.users)..where((u) => u.username.equals(username));
      final user = await query.getSingleOrNull();

      if (user != null) {
        _isAuthenticated = true;
        rehabProvider.setCurrentUser(user.id, user.fullName);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Помилка біометричного входу: $e");
      return false;
    }
  }

  // 2. ВХІД ЗА ПАРОЛЕМ (позиційні аргументи)
  Future<bool> loginWithPassword(String username, String password, RehabProvider rehabProvider) async {
    try {
      final query = _db.select(_db.users)
        ..where((u) => u.username.equals(username))
        ..where((u) => u.passwordHash.equals(password)); // Перевірка хэшу або паролю
      
      final user = await query.getSingleOrNull();

      if (user != null) {
        _isAuthenticated = true;
        rehabProvider.setCurrentUser(user.id, user.fullName);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Помилка входу за паролем: $e");
      return false;
    }
  }

  // 3. РЕЄСТРАЦІЯ ЛІКАРЯ (іменовані параметри)
  // Примітка: Якщо в login_screen.dart ти викликаєш цей метод без імен полей,
  // просто прибери фігурні дужки {} з параметрів нижче.
  Future<bool> registerDoctor({
    required String username,
    required String password,
    required String fullName,
  }) async {
    try {
      // Тут працює твоя стандартна логіка вставки в Drift БД
      // Після успішного додавання оновлюємо список збережених користувачів
      await _loadSavedUsers();
      return true;
    } catch (e) {
      debugPrint("Помилка реєстрації лікаря: $e");
      return false;
    }
  }

  // Вихід із системи
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
