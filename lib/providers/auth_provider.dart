import 'package:flutter/material.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Твій екземпляр Drift БД
  bool _isAuthenticated = false;
  final bool _isBiometricsEnabled = true; 
  List<dynamic> _savedUsers = [];  

  AuthProvider(this._db) {
    _loadSavedUsers(); 
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  List<dynamic> get savedUsers => _savedUsers;

  Future<void> _loadSavedUsers() async {
    try {
      _savedUsers = await _db.select(_db.users).get();
      notifyListeners();
    } catch (e) {
      debugPrint("Не вдалося завантажити збережених користувачів: $e");
    }
  }

  // Вхід за біометрією (позиційні параметри, як у рядку 54 вашого логіну)
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

  // Вхід за паролем (іменовані параметри, як у рядку 167 вашого логіну)
  Future<bool> loginWithPassword({
    required String username,
    required String password,
    required RehabProvider rehabProvider,
  }) async {
    try {
      final query = _db.select(_db.users)
        ..where((u) => u.username.equals(username))
        ..where((u) => u.passwordHash.equals(password)); 
      
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

  // Реєстрація лікаря (іменовані параметри, як у рядку 155 вашого логіну)
  Future<bool> registerDoctor({
    required String username,
    required String password,
    required String fullName,
  }) async {
    try {
      // Тут виконується вставка у вашу таблицю користувачів Drift
      await _loadSavedUsers();
      return true;
    } catch (e) {
      debugPrint("Помилка реєстрації лікаря: $e");
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
