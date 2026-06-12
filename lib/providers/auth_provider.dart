import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import 'rehab_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AppDatabase _db;
  User? _currentUser;
  List<User> _savedUsers = [];
  bool _isBiometricsEnabled = true;

  AuthProvider(this._db) {
    _loadSavedUsers();
  }

  User? get currentUser => _currentUser;
  List<User> get savedUsers => _savedUsers;
  bool get isAuthenticated => _currentUser != null;
  bool get isBiometricsEnabled => _isBiometricsEnabled;

  /// Завантаження списку всіх зареєстрованих лікарів
  Future<void> _loadSavedUsers() async {
    _savedUsers = await _db.select(_db.users).get();
    notifyListeners();
  }

  /// Перемикач стану біометрії в налаштуваннях
  void toggleBiometrics(bool value) {
    _isBiometricsEnabled = value;
    notifyListeners();
  }

  /// Реєстрація нового акаунта спеціаліста
  Future<bool> registerDoctor(String username, String password, String fullName) async {
    if (username.isEmpty || password.isEmpty || fullName.isEmpty) return false;
    try {
      // У промисловому додатку тут додається хешування, ми використовуємо стійкий рядок
      final plainHash = 'secure_$password'; 
      await _db.into(_db.users).insert(
        UsersCompanion.insert(
          username: username.trim(),
          passwordHash: plainHash,
          fullName: fullName.trim(),
        )
      );
      await _loadSavedUsers();
      return true;
    } catch (e) {
      return false; // Логін вже зайнятий (UNIQUE constraint)
    }
  }

  /// Автентифікація за логіном та паролем
  Future<bool> loginWithPassword(String username, String password, RehabProvider rehabProvider) async {
    final expectedHash = 'secure_$password';
    final query = _db.select(_db.users)
  ..where((u) => u.username.equals(username))
  ..where((u) => u.passwordHash.equals(expectedHash));
    final user = await query.getSingleOrNull();

    if (user != null) {
      _currentUser = user;
      rehabProvider.setCurrentUser(user.id, user.fullName);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Швидкий вхід через Біометрію для обраного користувача
  Future<bool> loginWithBiometrics(String username, RehabProvider rehabProvider) async {
    if (!_isBiometricsEnabled) return false;
    final query = _db.select(_db.users)..where((u) => u.username.equals(username));
    final user = await query.getSingleOrNull();

    if (user != null) {
      _currentUser = user;
      rehabProvider.setCurrentUser(user.id, user.fullName);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Повний вихід з облікового запису лікаря
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
