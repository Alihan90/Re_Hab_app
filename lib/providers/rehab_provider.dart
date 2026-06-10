import 'package:flutter/material.dart';
import '../models/clinical_models.dart';

class RehabProvider with ChangeNotifier {
  // --- Твої існуючі списки та логіка (збережено) ---
  final List<RehabExercise> _exercises = [];
  
  List<RehabExercise> get exercises => [..._exercises];

  // --- НОВА ЛОГІКА ДЛЯ КЛІНІЧНИХ ШКАЛ ---
  
  // Список всіх результатів тестувань (реактивна база даних)
  final List<AssessmentResult> _assessmentResults = [];

  // Геттер для отримання всіх результатів
  List<AssessmentResult> get assessmentResults => [..._assessmentResults];

  // Метод для отримання результатів конкретного пацієнта
  List<AssessmentResult> getResultsForPatient(String patientId) {
    return _assessmentResults
        .where((result) => result.patientId == patientId)
        .toList();
  }

  // Метод для збереження результату будь-якого тесту (ODI, 6MWT, RASS і т.д.)
  void saveAssessmentResult({
    required String patientId,
    required String scaleId,
    required Map<String, double> answers,
    required double totalScore,
    required double calculatedIndex,
    required String interpretation,
    Map<String, String>? vitalsData,
  }) {
    final newResult = AssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      scaleId: scaleId,
      date: DateTime.now(),
      answers: answers,
      totalScore: totalScore,
      calculatedIndex: calculatedIndex,
      interpretation: interpretation,
      vitalsData: vitalsData,
    );

    _assessmentResults.add(newResult);
    
    // Повідомляємо всі слухачі (UI) про зміну даних
    notifyListeners();
  }

  // Метод для видалення результату (корисно для виправлення помилок лікаря)
  void deleteAssessmentResult(String resultId) {
    _assessmentResults.removeWhere((result) => result.id == resultId);
    notifyListeners();
  }

  // --- Решта твоїх існуючих методів для роботи з вправами ---
  void addExercise(RehabExercise exercise) {
    _exercises.add(exercise);
    notifyListeners();
  }

  void removeExercise(String id) {
    _exercises.removeWhere((ex) => ex.id == id);
    notifyListeners();
  }
}
