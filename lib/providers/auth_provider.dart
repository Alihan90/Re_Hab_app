import 'package:flutter/material.dart';
import 'package:drift/drift.dart'; // 1. ДОДАНО: Імпорт пакету Drift для роботи з типами виразів
import 'package:re_hab_app/providers/rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Твій екземпляр Drift БД
  bool _isAuthenticated = false;
  final bool _isBiometricsEnabled = true; 
  List<dynamic> _savedUsers = [];  

  // Поля стану для екранів авторизації
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._db) {
    _loadSavedUsers(); 
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  List<dynamic> get savedUsers => _savedUsers;

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
      // 2. ВИПРАВЛЕНО: Явно вказуємо тип аргументу (dynamic u) та кастимо результат в Expression<bool>
      final query = _db.select(_db.users)
        ..where((dynamic u) => u.username.equals(username) as Expression<bool>);
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
      _errorMessage = 'Помилка біометрії: $e'; 
      notifyListeners();
      return false;
    }
  }

  // Вхід за паролем
  Future<bool> loginWithPassword({
    String? email,
    String? username,
    required String password,
    required RehabProvider rehabProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final targetUser = username ?? email ?? '';

    try {
      // 3. ВИПРАВЛЕНО ТУТ: Додано "as Expression<bool>" для обох умов фільтрації,
      // щоб розробник Drift всередині додатка чітко розумів тип операції.
      final query = _db.select(_db.users)
        ..where((dynamic u) => u.username.equals(targetUser) as Expression<bool>)
        ..where((dynamic u) => u.passwordHash.equals(password) as Expression<bool>); 
      
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
      _errorMessage = 'Помилка бази даних: $e'; 
      notifyListeners();
      return false;
    }
  }

  // Реєстрація лікаря
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
      await _loadSavedUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Помилка реєстрації лікаря: $e");
      _isLoading = false;
      _errorMessage = 'Помилка реєстрації: $e'; 
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
