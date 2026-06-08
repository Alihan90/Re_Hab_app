class ScaleOption {
  final String textUk;
  final String textEn;
  final int score;

  const ScaleOption({
    required this.textUk,
    required this.textEn,
    required this.score,
  });
}

class ScaleQuestion {
  final String id;
  final String textUk;
  final String textEn;
  final List<ScaleOption> options;

  const ScaleQuestion({
    required this.id,
    required this.textUk,
    required this.textEn,
    required this.options,
  });
}

class ScaleAssessment {
  final String id;
  final String nameUk;
  final String nameEn;
  final String category; // Напр: "Неврологія", "Педіатрія"
  final String descriptionUk;
  final String descriptionEn;
  final List<ScaleQuestion> questions;

  const ScaleAssessment({
    required this.id,
    required this.nameUk,
    required this.nameEn,
    required this.category,
    required this.descriptionUk,
    required this.descriptionEn,
    required this.questions,
  });
}

// Результат проходження шкали пацієнтом для збереження в історію
class ScaleHistoryPoint {
  final DateTime date;
  final String scaleId;
  final String scaleNameUk;
  final int totalScore;
  final String interpretationUk;
  final Map<String, int> selectedAnswers; // QuestionID -> Score

  ScaleHistoryPoint({
    required this.date,
    required this.scaleId,
    required this.scaleNameUk,
    required this.totalScore,
    required this.interpretationUk,
    required this.selectedAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'scaleId': scaleId,
      'scaleNameUk': scaleNameUk,
      'totalScore': totalScore,
      'interpretationUk': interpretationUk,
      'selectedAnswers': selectedAnswers,
    };
  }

  factory ScaleHistoryPoint.fromJson(Map<String, dynamic> json) {
    return ScaleHistoryPoint(
      date: DateTime.parse(json['date'] as String),
      scaleId: json['scaleId'] as String,
      scaleNameUk: json['scaleNameUk'] as String,
      totalScore: json['totalScore'] as int,
      interpretationUk: json['interpretationUk'] as String,
      selectedAnswers: Map<String, int>.from(json['selectedAnswers'] as Map),
    );
  }
}
