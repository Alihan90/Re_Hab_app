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

  // Метод для збереження результатів інтерактивного тестування у базі даних
  Future<void> saveAssessmentResult({
    required int patientId,
    required String scaleId,
    required int score,
    required String interpretation,
  }) async {
    try {
      // Тут буде твоя реалізація роботи з Drift, наприклад:
      // await database.saveAssessment(patientId, scaleId, score, interpretation);
      
      // Імітуємо виконання успішної операції та оновлюємо слухачів UI
      notifyListeners();
    } catch (e) {
      debugPrint("Помилка при збереженні результатів тестування: $e");
      rethrow;
    }
  }

  // Метод для виходу з акаунту
  void logout() {
    _currentUserId = null;
    _currentUserName = null;
    notifyListeners();
  }
}
