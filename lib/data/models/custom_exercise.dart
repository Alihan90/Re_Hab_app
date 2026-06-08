class CustomExercise {
  final String id;
  final String title;
  String dosage;
  bool isCustomized;

  CustomExercise({
    required this.id,
    required this.title,
    required this.dosage,
    this.isCustomized = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dosage': dosage,
      'isCustomized': isCustomized,
    };
  }

  factory CustomExercise.fromJson(Map<String, dynamic> json) {
    return CustomExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      dosage: json['dosage'] as String,
      isCustomized: json['isCustomized'] as bool? ?? false,
    );
  }
}
