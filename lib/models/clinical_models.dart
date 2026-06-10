import 'dart:convert';

/// Модель реабілітаційної вправи
class RehabExercise {
  final String id;
  final String name;
  final String category; // Нейро, Орто, Кардіо, Загальна
  final String description;
  final String dosage; // Наприклад: "3 підходи по 10 разів"
  final bool isCustom; // Чи додана лікарем вручну

  const RehabExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.dosage,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'dosage': dosage,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory RehabExercise.fromMap(Map<String, dynamic> map) {
    return RehabExercise(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      dosage: map['dosage'],
      isCustom: map['isCustom'] == 1,
    );
  }
}

/// Модель одного пункту (питання) клінічної шкали
class ScaleItem {
  final int id;
  final String instruction; // Що зробити пацієнту / Нагляд
  final Map<int, String> scoreOptions; // Бали та їх розшифровка (напр: {0: 'Не здатний', 1: 'Потребує допомоги'})

  const ScaleItem({
    required this.id,
    required this.instruction,
    required this.scoreOptions,
  });
}

/// Модель результату проведеного тестування
class AssessmentResult {
  final String scaleName;
  final DateTime date;
  final int totalScore;
  final String interpretation;
  final Map<int, int> itemScores; // Попунктні оцінки для аналізу динаміки

  const AssessmentResult({
    required this.scaleName,
    required this.date,
    required this.totalScore,
    required this.interpretation,
    required this.itemScores,
  });

  String toJson() {
    return jsonEncode({
      'scaleName': scaleName,
      'date': date.toIso8601String(),
      'totalScore': totalScore,
      'interpretation': interpretation,
      'itemScores': itemScores.map((key, value) => MapEntry(key.toString(), value)),
    });
  }

  factory AssessmentResult.fromJson(String source) {
    final map = jsonDecode(source);
    return AssessmentResult(
      scaleName: map['scaleName'],
      date: DateTime.parse(map['date']),
      totalScore: map['totalScore'],
      interpretation: map['interpretation'],
      itemScores: (map['itemScores'] as Map).map((key, value) => MapEntry(int.parse(key), value as int)),
    );
  }
}
