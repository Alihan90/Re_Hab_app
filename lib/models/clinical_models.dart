import 'dart:convert';

/// Тип клінічної шкали або тесту
enum ScaleType {
  multiItem,    // Багатопунктові (Берг, Бартел, де кожен пункт має свої бали)
  selectRow,    // Вибір одного рядка з повним описом стану (RASS, Ешворт)
  vitalsProtocol // Фізіологічний протокол з замірами пульсу та тиску (Ортостатичний, Тілт)
}

/// Модель реабілітаційної вправи (залишається незмінною)
class RehabExercise {
  final String id;
  final String name;
  final String category;
  final String description;
  final String dosage;
  final bool isCustom;

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

/// Модель одного пункту для шкал типу multiItem або selectRow
class ScaleItem {
  final int id;
  final String instruction;
  final Map<int, String> scoreOptions; // Для RASS ключі можуть бути і відʼємними (-5...4)

  const ScaleItem({
    required this.id,
    required this.instruction,
    required this.scoreOptions,
  });
}

/// Мета-опис клінічної шкали для динамічного рендерингу UI
class ClinicalScaleMeta {
  final String id;
  final String name;
  final ScaleType type;
  final String description;
  final List<ScaleItem> items;

  const ClinicalScaleMeta({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.items,
  });
}

/// Модель результату проведеного тестування (підтримує збереження будь-яких типів тестів)
class AssessmentResult {
  final String scaleId;
  final String scaleName;
  final DateTime date;
  final int totalScore;
  final String interpretation;
  final Map<String, String> dynamicDetails; // Для збереження сирого вводу (напр. "АТ_лежачи: 120/80")

  const AssessmentResult({
    required this.scaleId,
    required this.scaleName,
    required this.date,
    required this.totalScore,
    required this.interpretation,
    this.dynamicDetails = const {},
  });

  String toJson() {
    return jsonEncode({
      'scaleId': scaleId,
      'scaleName': scaleName,
      'date': date.toIso8601String(),
      'totalScore': totalScore,
      'interpretation': interpretation,
      'dynamicDetails': dynamicDetails,
    });
  }

  factory AssessmentResult.fromJson(String source) {
    final map = jsonDecode(source);
    return AssessmentResult(
      scaleId: map['scaleId'] ?? '',
      scaleName: map['scaleName'],
      date: DateTime.parse(map['date']),
      totalScore: map['totalScore'],
      interpretation: map['interpretation'],
      dynamicDetails: Map<String, String>.from(map['dynamicDetails'] ?? {}),
    );
  }
}
