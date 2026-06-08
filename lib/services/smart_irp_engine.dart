import '../data/models/irp_plan.dart';
import '../data/models/custom_exercise.dart';
import '../data/models/exercise.dart';

class SmartIrpEngine {
  // Вбудований базовий клінічний каталог вправ для автономної роботи без інтернету
  final List<Exercise> _coreCatalog = [
    Exercise(
      id: 'EX_NEURO_01',
      titleUk: 'Дзеркальна терапія для відновлення моторної кори кисті',
      titleEn: 'Mirror therapy for motor cortex rehabilitation',
      category: 'Фізичні вправи',
      descriptionUk: 'Виконання синхронних рухів обома руками перед дзеркалом з акцентом на візуальну рецепцію парезної кінцівки.',
      descriptionEn: 'Synchronous movements of both hands in front of a mirror focusing on the paretic limb.',
      indicationsUk: 'Інсульт, геміпарез, травми ЦНС',
      indicationsEn: 'Stroke, hemiparesis, CNS trauma',
      contraindicationsUk: 'Виражений психомоторний збуджений стан, глибока деменція',
      contraindicationsEn: 'Severe psychomotor agitation, deep dementia',
      defaultDosage: '15 хвилин, 2 рази на день',
      executionStepsUk: ['Встановити дзеркало перпендикулярно', 'Приховати уражену руку', 'Дивитися на відображення здорової руки', 'Намагатися рухати двома руками одночасно'],
      ageGroup: ExerciseAgeGroup.adult,
      intensity: ExerciseIntensity.low,
    ),
    Exercise(
      id: 'EX_RESP_01',
      titleUk: 'Діафрагмальний контроль дихання з подовженим видихом',
      titleEn: 'Diaphragmatic breathing control',
      category: 'Дихальні вправи',
      descriptionUk: 'Дихання за участю нижніх відділів легень та м\'язів черевного преса для оптимізації SpO2.',
      descriptionEn: 'Breathing involving the lower lungs and abdominal muscles to optimize SpO2.',
      indicationsUk: 'ХОЗЛ, стан після ШВЛ, загальна толерантність до навантажень',
      indicationsEn: 'COPD, post-ventilator states, low exercise tolerance',
      contraindicationsUk: 'Гострий період пневмотораксу, внутрішні кровотечі',
      contraindicationsEn: 'Acute pneumothorax, internal bleeding',
      defaultDosage: '12 повторів, 3 серії щоденно',
      executionStepsUk: ['Покласти одну руку на груди, другу — на живіт', 'Повільний вдих носом (живіт піднімається)', 'Видих крізь зімкнуті губи (живіт втягується)'],
      ageGroup: ExerciseAgeGroup.all,
      intensity: ExerciseIntensity.low,
    ),
    Exercise(
      id: 'EX_ORTHO_01',
      titleUk: 'Ізометрична стабілізація колінного суглоба (квадрицепс)',
      titleEn: 'Isometric quad sets execution',
      category: 'Фізичні вправи',
      descriptionUk: 'Напруження чотириголового м\'яза стегна без зміни довжини волокна для збереження тонусу.',
      descriptionEn: 'Contraction of the quadriceps muscle without joint movement.',
      indicationsUk: 'Травми ОРА, артроз, післяопераційний період стабілізації суглобів',
      indicationsEn: 'Musculoskeletal trauma, osteoarthritis, post-op phase',
      contraindicationsUk: 'Гострий інфекційний процес у синовіальній сумці',
      contraindicationsEn: 'Acute infectious arthritis',
      defaultDosage: 'Утримання напруги 6 секунд, 15 повторень',
      executionStepsUk: ['Положення лежачи на спині з випрямленою ногою', 'Максимально притиснути підколінну ямку до кушетки', 'Утримувати напругу', 'Повільно розслабити м\'яз'],
      ageGroup: ExerciseAgeGroup.all,
      intensity: ExerciseIntensity.medium,
    ),
  ];

  /// Автоматично генерує повноцінний план ІРП на основі вхідних діагностичних критеріїв пацієнта
  IrpPlan autoGeneratePlan({
    required List<String> mkh10Codes,
    required String age,
    required int plannedDays,
    required String goalsSmart,
  }) {
    final List<CustomExercise> selectedExercises = [];

    // Визначення профілю нозології на основі кодів МКХ-10
    bool isNeurological = mkh10Codes.any((code) => code.toUpperCase().startsWith('I6') || code.toUpperCase().startsWith('G'));
    bool isOrthopedic = mkh10Codes.any((code) => code.toUpperCase().startsWith('M') || code.toUpperCase().startsWith('S'));

    // Фільтрація довідника
    for (var exercise in _coreCatalog) {
      if (isNeurological && exercise.id.contains('NEURO')) {
        selectedExercises.add(CustomExercise(id: exercise.id, title: exercise.titleUk, dosage: exercise.defaultDosage));
      }
      if (isOrthopedic && exercise.id.contains('ORTHO')) {
        selectedExercises.add(CustomExercise(id: exercise.id, title: exercise.titleUk, dosage: exercise.defaultDosage));
      }
      // Дихальні вправи додаються усім пацієнтам для профілактики застійних явищ
      if (exercise.category == 'Дихальні вправи') {
        selectedExercises.add(CustomExercise(id: exercise.id, title: exercise.titleUk, dosage: exercise.defaultDosage));
      }
    }

    // Захисний механізм: якщо коди специфічні й збігів немає — додаємо базовий комплекс
    if (selectedExercises.isEmpty) {
      for (var ex in _coreCatalog) {
        selectedExercises.add(CustomExercise(id: ex.id, title: ex.titleUk, dosage: ex.defaultDosage));
      }
    }

    // Динамічний розподіл та чергування вправ за днями реабілітації
    final Map<int, List<CustomExercise>> targetSchedule = {};
    
    for (int currentDay = 1; currentDay <= plannedDays; currentDay++) {
      final List<CustomExercise> daySpecificExercises = [];
      
      if (selectedExercises.length > 1) {
        if (currentDay % 2 != 0) {
          // Непарні дні: перша та третя вправи з вибірки
          daySpecificExercises.add(selectedExercises[0]);
          if (selectedExercises.length > 2) daySpecificExercises.add(selectedExercises[2]);
        } else {
          // Парні дні: друга вправа та специфічна дихальна
          daySpecificExercises.add(selectedExercises[1]);
          if (selectedExercises.length > 3) daySpecificExercises.add(selectedExercises[3]);
        }
      } else {
        daySpecificExercises.addAll(selectedExercises);
      }
      
      targetSchedule[currentDay] = daySpecificExercises;
    }

    return IrpPlan(
      goalsSmart: goalsSmart,
      mfkCodes: isNeurological ? 's750 (Структури нервової системи), b730 (Функції сили м\'язів)' : 's730 (Структури пов\'язані з рухом), b710 (Функції рухливості суглобів)',
      interventionPlan: 'Рекомендовано щоденне виконання призначеного комплексу вправ відповідно до індивідуального розкладу навантаження під контролем показників сатурації та ЧСС.',
      specialistName: '',
      rehabilitationCycle: 'Первинний',
      plannedDays: plannedDays,
      daysSchedule: targetSchedule,
    );
  }
}
