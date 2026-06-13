import 'package:flutter/material.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Твій екземпляр Drift БД
  bool _isAuthenticated = false;
  final bool _isBiometricsEnabled = true; 
  List<dynamic> _savedUsers = [];  

  // ДОДАНО: Поля стану, які шукають екрани авторизації та деталей
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._db) {
    _loadSavedUsers(); 
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  List<dynamic> get savedUsers => _savedUsers;

  // ДОДАНО: Геттери стану для UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadSavedUsers() async {
    try {
      _savedUsers = await _db.select(_db.users).get();
      notifyListeners();
    } catch (e) {
      debugPrint("Не вдалося завантажити збережених користувачів: $e");
    }
  }

  // Вхід за біометрією
  Future<bool> loginWithBiometrics(String username, RehabProvider rehabProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final query = _db.select(_db.users)..where((u) => u.username.equals(username));
      final user = await query.getSingleOrNull();

      if (user != null) {
        _isAuthenticated = true;
        rehabProvider.setCurrentUser(user.id, user.fullName);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Помилка біометричного входу: $e");
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Вхід за паролем (ОНОВЛЕНО: додано параметр email для сумісності з UI)
  Future<bool> loginWithPassword({
    String? email,
    String? username,
    required String password,
    required RehabProvider rehabProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Перестраховка: якщо UI шле email замість username, беремо його
    final targetUser = username ?? email ?? '';

    try {
      final query = _db.select(_db.users)
        ..where((u) => u.username.equals(targetUser))
        ..where((u) => u.passwordHash.equals(password)); 
      
      final user = await query.getSingleOrNull();

      if (user != null) {
        _isAuthenticated = true;
        rehabProvider.setCurrentUser(user.id, user.fullName);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      _errorMessage = 'Невірний email або пароль';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Помилка входу за паролем: $e");
      _isLoading = false;
      _errorMessage = 'Помилка з\'єднання з базою';
      notifyListeners();
      return false;
    }
  }

  // Реєстрація лікаря (ОНОВЛЕНО: додано параметр email для сумісності з UI)
  Future<bool> registerDoctor({
    String? email,
    String? username,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final targetUser = username ?? email ?? '';

    try {
      // Тут твоя майбутня логіка інсерту Drift
      await _loadSavedUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Помилка реєстрації лікаря: $e");
      _isLoading = false;
      _errorMessage = 'Помилка реєстрації';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
