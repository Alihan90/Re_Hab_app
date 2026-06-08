import 'dart:math' as math;
import '../data/models/goniometry.dart';

class GoniometerService {
  // Базовий вектор для калібрування (початкове положення телефону на суглобі)
  List<double>? _calibratedVector;

  /// Фіксує початкове просторове положення для відліку кута
  void calibrate(double x, double y, double z) {
    _calibratedVector = [x, y, z];
  }

  /// Скидає налаштування калібрування
  void resetCalibration() {
    _calibratedVector = null;
  }

  /// Перевіряє, чи пристрій відкалібрований
  bool get isCalibrated => _calibratedVector != null;

  /// Обчислює кут між відкаліброваним вектором та поточними координатами датчика
  int calculateAngle(double x, double y, double z) {
    if (_calibratedVector == null) return 0;

    final v1 = _calibratedVector!;
    final v2 = [x, y, z];

    // Скалярний добуток векторів
    final dotProduct = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
    
    // Довжини (модулі) векторів
    final mag1 = math.sqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]);
    final mag2 = math.sqrt(v2[0] * v2[0] + v2[1] * v2[1] + v2[2] * v2[2]);

    if (mag1 == 0 || mag2 == 0) return 0;

    // Обчислення косинуса кута з обмеженням діапазону для запобігання помилкам округлення
    double cosTheta = dotProduct / (mag1 * mag2);
    cosTheta = cosTheta.clamp(-1.0, 1.0);

    // Переведення з радіан у градуси
    final radians = math.acos(cosTheta);
    return (radians * 180 / math.pi).round();
  }

  /// Автоматично генерує експертний висновок на основі дефіциту амплітуди руху
  String generateConclusion(String jointName, String movementType, int measuredValue, int normalValue) {
    final deficit = normalValue - measuredValue;
    
    if (deficit <= 0) {
      return "Амплітуда руху суглоба повністю збережена ($measuredValue° при нормі $normalValue°). Дефіцит відсутній.";
    } else if (deficit <= 15) {
      return "Виявлено легке обмеження рухливості. Дефіцит становить $deficit°. Рекомендовано активні вправи на розтягнення.";
    } else if (deficit <= 35) {
      return "Виявлено помірне обмеження амплітуди руху. Дефіцит: $deficit°. Потребує цілеспрямованої терапії та засобів додаткового інвентаря.";
    } else {
      return "Увага! Зафіксовано виражене обмеження амплітуди (ризик формування контрактури). Дефіцит: $deficit°. Рекомендовані м'які пасивні мобілізації та дихальний супровід.";
    }
  }
}
