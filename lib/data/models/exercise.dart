enum ExerciseAgeGroup { child, adult, geriatric, all }
enum ExerciseIntensity { low, medium, high }

class Exercise {
  final String id;
  final String titleUk;
  final String titleEn;
  final String category; // Фізичні, дихальні, апаратні...
  final String descriptionUk;
  final String descriptionEn;
  final String indicationsUk;
  final String indicationsEn;
  final String contraindicationsUk;
  final String contraindicationsEn;
  final String defaultDosage;
  final List<String> executionStepsUk;
  final ExerciseAgeGroup ageGroup;
  final ExerciseIntensity intensity;

  const Exercise({
    required this.id,
    required this.titleUk,
    required this.titleEn,
    required this.category,
    required this.descriptionUk,
    required this.descriptionEn,
    required this.indicationsUk,
    required this.indicationsEn,
    required this.contraindicationsUk,
    required this.contraindicationsEn,
    required this.defaultDosage,
    required this.executionStepsUk,
    required this.ageGroup,
    required this.intensity,
  });
}
