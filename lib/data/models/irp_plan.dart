import 'custom_exercise.dart';

class IrpPlan {
  String goalsSmart;
  String mfkCodes;
  String interventionPlan;
  String specialistName;
  String rehabilitationCycle;
  int plannedDays;
  Map<int, List<CustomExercise>> daysSchedule; // День (1, 2, 3...) -> Список вправ

  IrpPlan({
    this.goalsSmart = '',
    this.mfkCodes = '',
    this.interventionPlan = '',
    this.specialistName = '',
    this.rehabilitationCycle = 'Первинний',
    this.plannedDays = 3,
    Map<int, List<CustomExercise>>? daysSchedule,
  }) : daysSchedule = daysSchedule ?? {};

  Map<String, dynamic> toJson() {
    return {
      'goalsSmart': goalsSmart,
      'mfkCodes': mfkCodes,
      'interventionPlan': interventionPlan,
      'specialistName': specialistName,
      'rehabilitationCycle': rehabilitationCycle,
      'plannedDays': plannedDays,
      'daysSchedule': daysSchedule.map((key, value) => MapEntry(key.toString(), value.map((e) => e.toJson()).toList())),
    };
  }

  factory IrpPlan.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['daysSchedule'] as Map<String, dynamic>? ?? {};
    final Map<int, List<CustomExercise>> parsedSchedule = {};
    
    rawSchedule.forEach((key, value) {
      final dayNumber = int.parse(key);
      final exerciseList = (value as List).map((e) => CustomExercise.fromJson(e as Map<String, dynamic>)).toList();
      parsedSchedule[dayNumber] = exerciseList;
    });

    return IrpPlan(
      goalsSmart: json['goalsSmart'] as String? ?? '',
      mfkCodes: json['mfkCodes'] as String? ?? '',
      interventionPlan: json['interventionPlan'] as String? ?? '',
      specialistName: json['specialistName'] as String? ?? '',
      rehabilitationCycle: json['rehabilitationCycle'] as String? ?? 'Первинний',
      plannedDays: json['plannedDays'] as int? ?? 3,
      daysSchedule: parsedSchedule,
    );
  }
}
