import 'package:flutter/material.dart';

// Тимчасові класи-заглушки для сумісності типів (якщо вони ще не імпортовані)
class MockPatient {
  final int id;
  final String fullName;
  final bool isActive;
  MockPatient({required this.id, required this.fullName, this.isActive = true});
}

class MockExercise {
  final String id;
  final String name;
  final bool isCustom;
  MockExercise({required this.id, required this.name, this.isCustom = false});
}

class RehabProvider with ChangeNotifier {
  final dynamic database; // Твоя база даних Drift
  int? _currentUserId;
  String? _currentUserName;

  // Поля для налаштувань UI
  String _locale = 'uk';
  bool _isDarkMode = false;

  // Списки даних (заглушки, які ти потім зв'яжеш із Drift)
  List<MockPatient> _patients = [];
  List<MockExercise> _exercises = [];

  RehabProvider(this.database);

  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  
  // Геттери, які вимагав UI
  String get locale => _locale;
  bool get isDarkMode => _isDarkMode;
  List<MockPatient> get patients => _patients;
  List<MockExercise> get exercises => _exercises;

  void setCurrentUser(int id, String fullName) {
    _currentUserId = id;
    _currentUserName = fullName;
    notifyListeners();
  }

  // Перемикання теми
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Зміна мови
  void setLocale(String lang) {
    _locale = lang;
    notifyListeners();
  }

  // Додавання пацієнта
  Future<void> addPatient({
    required String fullName,
    required DateTime dateOfBirth,
    required int treatmentDays,
    required String icdCode,
    required String diagnosis,
    String? complaints,
    String? expectations,
  }) async {
    // Тут буде реальний Drift insert. Поки додаємо в локальний список:
    _patients.add(MockPatient(id: _patients.length + 1, fullName: fullName, isActive: true));
    notifyListeners();
  }

  // Додавання власної вправи лікаря
  Future<void> addCustomExercise(String patientId, String exerciseName) async {
    _exercises.add(MockExercise(id: _exercises.length.toString(), name: exerciseName, isCustom: true));
    notifyListeners();
  }

  // Отримання історії тестувань для конкретного пацієнта
  List<dynamic> getAssessmentsForPatient(String patientId) {
    return []; // Повертає список результатів із бази даних
  }

  Future<void> saveAssessmentResult({
    required int patientId,
    required String scaleId,
    required int score,
    required String interpretation,
  }) async {
    try {
      notifyListeners();
    } catch (e) {
      debugPrint("Помилка: $e");
      rethrow;
    }
  }

  void logout() {
    _currentUserId = null;
    _currentUserName = null;
    notifyListeners();
  }
}
