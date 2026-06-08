class VitalSigns {
  final int heartRate;          // ЧСС (ударів за хвилину)
  final String bloodPressure;   // А/Т (наприклад, "120/80")
  final int oxygenSaturation;   // SpO2 (%)

  const VitalSigns({
    required this.heartRate,
    required this.bloodPressure,
    required this.oxygenSaturation,
  });

  // Конвертація у JSON для збереження в локальну БД
  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'oxygenSaturation': oxygenSaturation,
    };
  }

  // Створення об'єкта з JSON
  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      heartRate: json['heartRate'] as int,
      bloodPressure: json['bloodPressure'] as String,
      oxygenSaturation: json['oxygenSaturation'] as int,
    );
  }
}
