import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Твій екземпляр Drift БД
  bool _isAuthenticated = false;
  List<dynamic> _savedUsers = [];  

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._db) {
    refreshUsers(); 
  }

  bool get isAuthenticated => _isAuthenticated;
  List<dynamic> get savedUsers => _savedUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Оновлення списку спеціалістів із бази даних
  Future<void> refreshUsers() async {
    try {
      _savedUsers = await _db.select(_db.users).get();
      notifyListeners();
    } catch (e) {
      debugPrint("Не вдалося завантажити користувачів: $e");
    }
  }

  // ВХІД: Просто беремо обраного із списку лікаря й передаємо в систему
  Future<bool> loginWithSelectedUser(dynamic user, RehabProvider rehabProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isAuthenticated = true;
      // Передаємо ID та повне ім'я спеціаліста в RehabProvider для відображення в картах пацієнтів
      rehabProvider.setCurrentUser(user.id, user.fullName);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Помилка входу: $e';
      notifyListeners();
      return false;
    }
  }

  // РЕЄСТРАЦІЯ: Створюємо новий профіль у базі даних та одразу заходимо
  Future<bool> createProfileAndLogin({
    required String name,
    required String role,
    required RehabProvider rehabProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Формуємо красиве відображення профілю для документів, наприклад: "Іван Іванов (Фізичний терапевт)"
      final displayName = "$name ($role)";
      
      // Робимо прямий SQL інсерт у базу даних, щоб уникнути конфліктів із генерацією кодів Drift
      await _db.customInsert(
        'INSERT INTO users (username, password_hash, full_name) VALUES (?, ?, ?)',
        variables: [Variable(name), Variable('no_password'), Variable(displayName)],
      );

      // Перечитуємо базу, щоб новий користувач з'явився у списку
      await refreshUsers();

      // Шукаємо його в оновленому списку, щоб виконати авто-вхід
      final dynamic newUser = _savedUsers.firstWhere(
        (u) => u.username == name,
        orElse: () => null,
      );

      if (newUser != null) {
        _isAuthenticated = true;
        rehabProvider.setCurrentUser(newUser.id, newUser.fullName);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Профіль створено, але виберіть його зі списку для входу.';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Помилка створення профілю: $e");
      _isLoading = false;
      _errorMessage = 'Не вдалося зберегти в базу: $e';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
