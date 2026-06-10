import 'dart:convert';

/// Тип клінічної шкали або тесту (збережено та розширено під нові типи)
enum ScaleType {
  multiItem,      // Багатопунктові (Берг, Бартел, ODI, WOMAC, DASH, когнітивні тести)
  selectRow,      // Вибір одного рядка з повним описом стану (RASS, Ешворт, mMRC, NYHA)
  vitalsProtocol, // Фізіологічний протокол з замірами пульсу та тиску (6MWT, Шатл-тести)
}

/// Модель реабілітаційної вправи (залишилась незмінною з твого коду)
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
      'isCustom': isCustom,
    };
  }

  factory RehabExercise.fromMap(Map<String, dynamic> map) {
    return RehabExercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      dosage: map['dosage'] ?? '',
      isCustom: map['isCustom'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory RehabExercise.fromJson(String source) => RehabExercise.fromMap(json.decode(source));
}

/// --- НОВА МОДЕЛЬ: Опція відповіді в питанні ---
class ScaleOption {
  final double score;
  final String text;

  const ScaleOption({
    required this.score,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'text': text,
    };
  }

  factory ScaleOption.fromMap(Map<String, dynamic> map) {
    return ScaleOption(
      score: (map['score'] as num).toDouble(),
      text: map['text'] ?? '',
    );
  }
}

/// --- НОВА МОДЕЛЬ: Секція або окреме питання шкали ---
class ScaleSection {
  final String id;
  final String title;
  final String description;
  final List<ScaleOption> options;

  const ScaleSection({
    required this.id,
    required this.title,
    this.description = '',
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'options': options.map((x) => x.toMap()).toList(),
    };
  }

  factory ScaleSection.fromMap(Map<String, dynamic> map) {
    return ScaleSection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      options: List<ScaleOption>.from(map['options']?.map((x) => ScaleOption.fromMap(x)) ?? const []),
    );
  }
}

/// --- НОВА МОДЕЛЬ: Опис структури будь-якої клінічної шкали ---
class ClinicalScale {
  final String id;
  final String name;
  final String category;
  final ScaleType type;
  final String description;
  final List<ScaleSection> sections;
  final double maxRawScore;

  const ClinicalScale({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.description,
    required this.sections,
    required this.maxRawScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type.index,
      'description': description,
      'sections': sections.map((x) => x.toMap()).toList(),
      'maxRawScore': maxRawScore,
    };
  }

  factory ClinicalScale.fromMap(Map<String, dynamic> map) {
    return ClinicalScale(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      type: ScaleType.values[map['type'] ?? 0],
      description: map['description'] ?? '',
      sections: List<ScaleSection>.from(map['sections']?.map((x) => ScaleSection.fromMap(x)) ?? const []),
      maxRawScore: (map['maxRawScore'] as num).toDouble(),
    );
  }
}

/// --- НОВА МОДЕЛЬ: Результат оцінювання пацієнта ---
class AssessmentResult {
  final String id;
  final String patientId;
  final String scaleId;
  final DateTime date;
  final Map<String, double> answers; // Ключ: ID питання, Значення: вибраний бал
  final double totalScore;
  final double calculatedIndex;     // Відсотки чи специфічні індекси (напр. ODI %, DASH %)
  final String interpretation;
  final Map<String, String>? vitalsData; // Для протоколів типу 6MWT (пульс, тиск, SpO2)

  AssessmentResult({
    required this.id,
    required this.patientId,
    required this.scaleId,
    required this.date,
    required this.answers,
    required this.totalScore,
    required this.calculatedIndex,
    required this.interpretation,
    this.vitalsData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'scaleId': scaleId,
      'date': date.toIso8601String(),
      'answers': answers,
      'totalScore': totalScore,
      'calculatedIndex': calculatedIndex,
      'interpretation': interpretation,
      'vitalsData': vitalsData,
    };
  }

  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    return AssessmentResult(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      scaleId: map['scaleId'] ?? '',
      date: DateTime.parse(map['date']),
      answers: Map<String, double>.from(map['answers'] ?? {}),
      totalScore: (map['totalScore'] as num).toDouble(),
      calculatedIndex: (map['calculatedIndex'] as num).toDouble(),
      interpretation: map['interpretation'] ?? '',
      vitalsData: map['vitalsData'] != null ? Map<String, String>.from(map['vitalsData']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AssessmentResult.fromJson(String source) => AssessmentResult.fromMap(json.decode(source));
}
