class JointMovementNorm {
  final String jointNameUk;
  final String movementTypeUk;
  final int normalValueDegrees;
  final String instructionUk;

  const JointMovementNorm({
    required this.jointNameUk,
    required this.movementTypeUk,
    required this.normalValueDegrees,
    required this.instructionUk,
  });
}

class GoniometryResult {
  final String jointNameUk;
  final String movementTypeUk;
  final int measuredValueDegrees;
  final int normalValueDegrees;
  final DateTime date;
  final String conclusionUk;

  GoniometryResult({
    required this.jointNameUk,
    required this.movementTypeUk,
    required this.measuredValueDegrees,
    required this.normalValueDegrees,
    required this.date,
    required this.conclusionUk,
  });

  Map<String, dynamic> toJson() {
    return {
      'jointNameUk': jointNameUk,
      'movementTypeUk': movementTypeUk,
      'measuredValueDegrees': measuredValueDegrees,
      'normalValueDegrees': normalValueDegrees,
      'date': date.toIso8601String(),
      'conclusionUk': conclusionUk,
    };
  }

  factory GoniometryResult.fromJson(Map<String, dynamic> json) {
    return GoniometryResult(
      jointNameUk: json['jointNameUk'] as String,
      movementTypeUk: json['movementTypeUk'] as String,
      measuredValueDegrees: json['measuredValueDegrees'] as int,
      normalValueDegrees: json['normalValueDegrees'] as int,
      date: DateTime.parse(json['date'] as String),
      conclusionUk: json['conclusionUk'] as String,
    );
  }
}
