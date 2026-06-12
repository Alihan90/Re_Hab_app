import 'package:flutter/material.dart';

class RehabProvider with ChangeNotifier {
  final dynamic database; // Сюди зберігається твоя БД (AppDatabase)
  int? _currentUserId;
  String? _currentUserName;

  // ВІДКОРИГОВАНИЙ КОНСТРУКТОР: тепер він приймає базу даних
  RehabProvider(this.database);

  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  // ДОДАНИЙ МЕТОД: для збереження поточного користувача після авторизації
  void setCurrentUser(int id, String fullName) {
    _currentUserId = id;
    _currentUserName = fullName;
    notifyListeners();
  }
}
