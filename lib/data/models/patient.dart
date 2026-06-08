import 'irp_plan.dart';
import 'patient_visit.dart';
import 'scale_assessment.dart';
import 'goniometry.dart';

class Patient {
  final String id;
  String nameUk;
  String nameEn;
  String age;
  String birthDate;
  String generalDiagnosisUk;
  String generalDiagnosisEn;
  List<String> diagnosisMkh10Codes;
  String admissionDate;
  final IrpPlan irp;
  final List<PatientVisit> visits;
  final List<ScaleHistoryPoint> scaleHistory;
  final List<GoniometryResult> goniometryHistory;

  Patient({
    required this.id,
    required this.nameUk,
    required this.nameEn,
    required this.age,
    required this.birthDate,
    required this.generalDiagnosisUk,
    required this.generalDiagnosisEn,
    required this.diagnosisMkh10Codes,
    required this.admissionDate,
    required this.irp,
    List<PatientVisit>? visits,
    List<ScaleHistoryPoint>? scaleHistory,
    List<GoniometryResult>? goniometryHistory,
  })  : visits = visits ?? [],
        scaleHistory = scaleHistory ?? [],
        goniometryHistory = goniometryHistory ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameUk': nameUk,
      'nameEn': nameEn,
      'age': age,
      'birthDate': birthDate,
      'generalDiagnosisUk': generalDiagnosisUk,
      'generalDiagnosisEn': generalDiagnosisEn,
      'diagnosisMkh10Codes': diagnosisMkh10Codes,
      'admissionDate': admissionDate,
      'irp': irp.toJson(),
      'visits': visits.map((e) => e.toJson()).toList(),
      'scaleHistory': scaleHistory.map((e) => e.toJson()).toList(),
      'goniometryHistory': goniometryHistory.map((e) => e.toJson()).toList(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      nameUk: json['nameUk'] as String,
      nameEn: json['nameEn'] as String,
      age: json['age'] as String,
      birthDate: json['birthDate'] as String,
      generalDiagnosisUk: json['generalDiagnosisUk'] as String,
      generalDiagnosisEn: json['generalDiagnosisEn'] as String,
      diagnosisMkh10Codes: List<String>.from(json['diagnosisMkh10Codes'] as List),
      admissionDate: json['admissionDate'] as String,
      irp: IrpPlan.fromJson(json['irp'] as Map<String, dynamic>),
      visits: (json['visits'] as List?)?.map((e) => PatientVisit.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      scaleHistory: (json['scaleHistory'] as List?)?.map((e) => ScaleHistoryPoint.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      goniometryHistory: (json['goniometryHistory'] as List?)?.map((e) => GoniometryResult.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
