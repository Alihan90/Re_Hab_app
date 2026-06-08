import 'vital_signs.dart';

class PatientVisit {
  final String id;
  final DateTime date;
  String therapeuticNote;
  final VitalSigns vitals;
  final Map<String, String> scaleResultsAtVisit; // Назва шкали -> Результат/Бал

  PatientVisit({
    required this.id,
    required this.date,
    required this.therapeuticNote,
    required this.vitals,
    Map<String, String>? scaleResultsAtVisit,
  }) : scaleResultsAtVisit = scaleResultsAtVisit ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'therapeuticNote': therapeuticNote,
      'vitals': vitals.toJson(),
      'scaleResultsAtVisit': scaleResultsAtVisit,
    };
  }

  factory PatientVisit.fromJson(Map<String, dynamic> json) {
    return PatientVisit(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      therapeuticNote: json['therapeuticNote'] as String,
      vitals: VitalSigns.fromJson(json['vitals'] as Map<String, dynamic>),
      scaleResultsAtVisit: Map<String, String>.from(json['scaleResultsAtVisit'] as Map),
    );
  }
}
