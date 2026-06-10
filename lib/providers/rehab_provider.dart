import 'package:flutter/material.dart';
import '../models/clinical_models.dart';
import '../data/repositories/clinical_repository.dart';

class RehabProvider extends ChangeNotifier {
  // Список пацієнтів (імітація зв'язку з Drift без руйнування архітектури)
  final List<dynamic> _patients = [];
  
  // Список вправ (вбудовані + додані лікарем)
  List<RehabExercise> _exercises = [...ClinicalRepository.defaultExercises];

  // Мапа результатів тестувань за шкалами, прив'язана до ID пацієнта: { patientId: [AssessmentResult] }
  final Map<String, List<AssessmentResult>> _patientAssessments = {};

  List<dynamic> get patients => _patients;
  List<RehabExercise> get exercises => _exercises;

  /// Отримання результатів тестувань для конкретного пацієнта
  List<AssessmentResult> getAssessmentsForPatient(String patientId) {
    return _patientAssessments[patientId] ?? [];
  }

  /// Метод додавання пацієнта (розширений параметрами скарг, очікувань та днів)
  void addPatient({
    required String fullName,
    required String diagnosis,
    required String icdCode,
    required DateTime dateOfBirth,
    String? complaints,
    String? expectations,
    required int treatmentDays,
  }) {
    // Створюємо mock-об'єкт, структура якого повністю відповідає генерації полів Drift
    final newPatient = _MockPatient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      diagnosis: diagnosis,
      icdCode: icdCode,
      dateOfBirth: dateOfBirth,
      complaints: complaints,
      expectations: expectations,
      treatmentDays: treatmentDays,
    );
    
    _patients.add(newPatient);
    notifyListeners();
  }

  /// 🟢 НОВЕ: Можливість лікаря самостійно розширювати базу вправ у додатку
  void addCustomExercise({
    required String name,
    required String category,
    required String description,
    required String dosage,
  }) {
    final customEx = RehabExercise(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      description: description,
      dosage: dosage,
      isCustom: true,
    );
    _exercises.add(customEx);
    notifyListeners();
  }

  /// 🟢 НОВЕ: Збереження результатів проведеного інтерактивного тестування за шкалою
  void saveAssessment(String patientId, AssessmentResult result) {
    if (!_patientAssessments.containsKey(patientId)) {
      _patientAssessments[patientId] = [];
    }
    _patientAssessments[patientId]!.add(result);
    notifyListeners();
  }
}

/// Допоміжний клас-контейнер для збереження цілісності інтерфейсу
class _MockPatient {
  final String id;
  final String fullName;
  final String diagnosis;
  final String icdCode;
  final DateTime dateOfBirth;
  final String? complaints;
  final String? expectations;
  final int treatmentDays;

  _MockPatient({
    required this.id,
    required this.fullName,
    required this.diagnosis,
    required this.icdCode,
    required this.dateOfBirth,
    this.complaints,
    this.expectations,
    required this.treatmentDays,
  });
}
