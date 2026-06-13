import 'package:flutter/material.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Інстанс твоєї бази даних
  bool _isAuthenticated = false; // Геттер, який обов'язково потрібен для main.dart

  AuthProvider(this._db);

  // Додано геттер, щоб main.dart розумів, який екран показувати (Login чи Hub)
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login({
    required String username,
    required String expectedHash,
    required RehabProvider rehabProvider,
  }) async {
    try {
      // Безпечний синтаксис Drift (каскад умов через AND)
      final query = _db.select(_db.users)
        ..where((u) => u.username.equals(username))
        ..where((u) => u.passwordHash.equals(expectedHash));
      
      final user = await query.getSingleOrNull();

      if (user != null) {
        _isAuthenticated = true;
        // Передаємо дані успішної авторизації в RehabProvider
        rehabProvider.setCurrentUser(user.id, user.fullName);
        notifyListeners(); // Оновлюємо інтерфейс (main.dart переключить екран)
        return true;
      }
      
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Помилка авторизації в AuthProvider: $e");
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // Метод для скидання стану авторизації при виході
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
