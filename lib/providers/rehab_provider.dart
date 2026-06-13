import 'package:flutter/material.dart';

class RehabProvider with ChangeNotifier {
  final dynamic database; // Зберігає інстанс вашої бази даних Drift
  int? _currentUserId;
  String? _currentUserName;

  // ВИПРАВЛЕНИЙ КОНСТРУКТОР: тепер приймає базу даних позиційним аргументом
  RehabProvider(this.database);

  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  // ДОДАНИЙ МЕТОД: викликається після успішного логіну в AuthProvider
  void setCurrentUser(int id, String fullName) {
    _currentUserId = id;
    _currentUserName = fullName;
    notifyListeners();
  }

  // Метод для виходу з акаунту (опціонально, для зручності)
  void logout() {
    _currentUserId = null;
    _currentUserName = null;
    notifyListeners();
  }
}
