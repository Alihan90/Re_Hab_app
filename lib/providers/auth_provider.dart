import 'package:flutter/material.dart';
import 'rehab_provider.dart';

class AuthProvider with ChangeNotifier {
  final dynamic _db; // Інстанс вашої бази даних

  AuthProvider(this._db);

  Future<bool> login({
    required String username,
    required String expectedHash,
    required RehabProvider rehabProvider,
  }) async {
    try {
      // БЕЗПЕЧНИЙ СИНТАКСИС DRIFT: об'єднуємо умови через каскад, без оператора '&'
      final query = _db.select(_db.users)
        ..where((u) => u.username.equals(username))
        ..where((u) => u.passwordHash.equals(expectedHash));
      
      final user = await query.getSingleOrNull();

      if (user != null) {
        // Передаємо дані успішної авторизації в RehabProvider
        rehabProvider.setCurrentUser(user.id, user.fullName);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Помилка авторизації в AuthProvider: $e");
      return false;
    }
  }
}
