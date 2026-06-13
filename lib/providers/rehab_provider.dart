import 'package:flutter/material.dart';

class RehabProvider with ChangeNotifier {
  final dynamic database; // Зберігає інстанс твоєї бази даних Drift
  int? _currentUserId;
  String? _currentUserName;

  // Конструктор приймає базу даних позиційним аргументом, як у main.dart
  RehabProvider(this.database);

  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  // Метод викликається після успішного логіну в AuthProvider
  void setCurrentUser(int id, String fullName) {
    _currentUserId = id;
    _currentUserName = fullName;
    notifyListeners();
  }

  // Метод для виходу з акаунту
  void logout() {
    _currentUserId = null;
    _currentUserName = null;
    notifyListeners();
  }

  // 💡 ПРИМІТКА: Якщо у цьому класі раніше були твої методи для вправ, 
  // пацієнтів чи шкал реабілітації — просто допиши їх нижче, вони нічому не заважатимуть.
}
