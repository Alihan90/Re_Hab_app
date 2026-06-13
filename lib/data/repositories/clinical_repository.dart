import 'package:re_hab_app/models/clinical_models.dart';

class ClinicalRepository {
  /// Базова база вправ
  static const List<RehabExercise> defaultExercises = [
    RehabExercise(
      id: 'neuro_01',
      name: 'Бобат-ініціація перевертання',
      category: 'Нейрореабілітація',
      description: 'Фасилітація перевертання зі спини на бік за допомогою контролю та навантаження лопатки та тазового сегмента.',
      dosage: '10-12 перевертань на кожен бік, 2 сесії на день',
    ),
    RehabExercise(
      id: 'neuro_02',
      name: 'PNF-паттерн для верхньої кінцівки (D1 Флексія)',
      category: 'Нейрореабілітація',
      description: 'Діагональне полегшення руху руки від розгинання-відведення-внутрішньої ротації до згинання-приведення-зовнішньої ротації.',
      dosage: '3 підходи по 10 повторень з ручним опором терапевта',
    ),
    RehabExercise(
      id: 'neuro_03',
      name: 'Дзеркальна терапія (Mirror Therapy)',
      category: 'Нейрореабілітація',
      description: 'Виконання простих рухів здоровою рукою перед дзеркалом для візуальної стимуляції моторної кори ураженої півкулі.',
      dosage: '15-20 хвилин безперервного фокусування',
    ),
    RehabExercise(
      id: 'ortho_01',
      name: 'Ізометричне скорочення чотириголового м\'яза',
      category: 'Ортопедія/Травматологія',
      description: 'Притискання підколінної ямки до кушетки з утриманням напруги стегна без руху в колінному суглобі.',
      dosage: '3 підходи по 15 повторень, утримання напруги 5 секунд',
    ),
    RehabExercise(
      id: 'cardio_01',
      name: 'Діафрагмальний дренажний подих',
      category: 'Кардіо-респіраторна',
      description: 'Глибокий вдих носом із надуванням живота, тривалий видих ротом через складені трубочкою губи.',
      dosage: '8-10 дихальних циклів щогодини',
    ),
  ];

  /// ГЛОБАЛЬНИЙ РЕЄСТР КЛІНІЧНИХ ШКАЛ ТА ТЕСТІВ ДОДАТКУ (Синхронізовано з UI)
  static final List<ClinicalScale> allScales = [
    // 1. ШКАЛА RASS
    ClinicalScale(
      id: 'rass',
      name: 'Шкала ажитації-седації Річмонда (RASS)',
      type: ScaleType.selectRow,
      description: 'Оцінка рівня свідомості, психомоторного збудження або глибини седації пацієнта в палатах інтенсивної терапії та ранньої реабілітації.',
      maxRawScore: 4.0,
      sections: [
        ScaleSection(
          id: 'rass_1',
          title: 'Оберіть поточний психосоматичний статус пацієнта за критеріями спостереження:',
          description: '',
          options: [
            ScaleOption(score: 4.0, text: '[+4 Бали] Буйний: Пацієнт агресивний, становить загрозу...'),
            ScaleOption(score: 3.0, text: '[+3 Бали] Дуже збуджений: Пацієнт здійснює хаотичні рухи...'),
            ScaleOption(score: 2.0, text: '[+2 Бали] Збуджений: Неагресивна рухова активність...'),
            ScaleOption(score: 1.0, text: '[+1 Бал] Неспокійний: Пацієнт тривожний, помірно напружений...'),
            ScaleOption(score: 0.0, text: '[0 Балів] Спокійний, уважний: Адекватно реагує, виконує команди...'),
            ScaleOption(score: -1.0, text: '[-1 Бал] Сонливий: Прокидається на голос, зоровий контакт >10с...'),
            ScaleOption(score: -2.0, text: '[-2 Бали] Легка седація: Короткий зоровий контакт <10с...'),
            ScaleOption(score: -3.0, text: '[-3 Бали] Помірна седація: Реагує на голос рухом, без зорового контакту...'),
            ScaleOption(score: -4.0, text: '[-4 Бали] Глибока седація: Не реагує на голос, реагує на біль...'),
            ScaleOption(score: -5.0, text: '[-5 Балів] Ареактивність (Кома): Відсутність будь-яких реакцій...'),
          ],
        ),
      ],
    ),

    // 2. МОДИФІКОВАНА ШКАЛА ЕШВОРТА
    ClinicalScale(
      id: 'ashworth',
      name: 'Модифікована шкала спастичності Ешворта (MAS)',
      type: ScaleType.selectRow,
      description: 'Клінічна оцінка тонусу м\'язів при пасивному згинанні/розгинанні кінцівки у пацієнтів з ураженням центрального нейрона.',
      maxRawScore: 5.0,
      sections: [
        ScaleSection(
          id: 'ashworth_1',
          title: 'Визначте ступінь опору м\'яза під час виконання швидкого пасивного руху кінцівки лікарем:',
          description: '',
          options: [
            ScaleOption(score: 0.0, text: '[0 Балів] Немає підвищення тонусу: Повний пасивний рух проходить гладко.'),
            ScaleOption(score: 1.0, text: '[1 Бал] Легке підвищення тонусу: Мінімальний опір в самому кінці амплітуди.'),
            ScaleOption(score: 2.0, text: '[2 Бали] Помірне підвищення тонусу (1+): Опір протягом меншої частини амплітуди.'),
            ScaleOption(score: 3.0, text: '[3 Бали] Значне підвищення тонусу: Виражене збільшення тонусу, але флексія легка.'),
            ScaleOption(score: 4.0, text: '[4 Бали] Тяжке підвищення тонусу: Пасивні рухи значно ускладнені.'),
            ScaleOption(score: 5.0, text: '[5 Балів] Контрактура/Рігідність: Пасивний рух неможливий.'),
          ],
        ),
      ],
    ),

    // 3. ОРТОСТАТИЧНА ПРОБА
    ClinicalScale(
      id: 'orthostatic_test',
      name: 'Ортостатична проба (Шелонг-протокол)',
      type: ScaleType.vitalsProtocol,
      description: 'Дослідження стану вегетативної нервової системи та серцево-судинної системи пацієнта при переході з горизонтального положення у вертикальне.',
      maxRawScore: 2.0,
      sections: [],
    ),

    // 4. ТІЛТ-ТЕСТ
    ClinicalScale(
      id: 'tilt_test',
      name: 'Тілт-тест (Пасивна ортостатична проба)',
      type: ScaleType.vitalsProtocol,
      description: 'Діагностика синкопальних станів невідомого генезу, оцінка барорецепторного рефлексу під впливом пасивної зміни положення тіла.',
      maxRawScore: 2.0,
      sections: [],
    ),

    // 5. ШКАЛА БЕРГА
    ClinicalScale(
      id: 'berg',
      name: 'Шкала балансу Берга (BBS)',
      type: ScaleType.multiItem,
      description: '14-пунктовий тест для оцінки функціонального балансу пацієнта.',
      maxRawScore: 56.0,
      sections: [
        ScaleSection(
          id: 'berg_1',
          title: 'Вставання з положення сидячи',
          description: '',
          options: [
            ScaleOption(score: 4.0, text: 'Встає без сторонньої допомоги, самостійно стабілізується'),
            ScaleOption(score: 3.0, text: 'Встає самостійно, але використовує руки для опори'),
            ScaleOption(score: 2.0, text: 'Встає самостійно після кількох спроб або з мінімальною підтримкою'),
            ScaleOption(score: 1.0, text: 'Потребує мінімальної допомоги, щоб підвестися або стабілізуватися'),
            ScaleOption(score: 0.0, text: 'Потребує помірної або максимальної допомоги, щоб встати'),
          ],
        ),
        ScaleSection(
          id: 'berg_2',
          title: 'Стояння без підтримки',
          description: '',
          options: [
            ScaleOption(score: 4.0, text: 'Здатний стояти безпечно протягом 2 хвилин'),
            ScaleOption(score: 3.0, text: 'Здатний стояти 2 хвилини под наглядом'),
            ScaleOption(score: 2.0, text: 'Здатний стояти 30 секунд без підтримки'),
            ScaleOption(score: 1.0, text: 'Потребує кількох спроб, щоб стояти 30 секунд без опори'),
            ScaleOption(score: 0.0, text: 'Не здатний стояти без сторонньої опори'),
          ],
        ),
      ],
    ),

    // 6. ІНДЕКС БАРТЕЛ
    ClinicalScale(
      id: 'barthel',
      name: 'Модифікований Індекс Бартел (ADL)',
      type: ScaleType.multiItem,
      description: 'Оцінка повсякденної активності та рівня побутової незалежності пацієнта.',
      maxRawScore: 100.0,
      sections: [
        ScaleSection(
          id: 'barthel_1',
          title: 'Харчування (прийом їжі)',
          description: '',
          options: [
            ScaleOption(score: 10.0, text: 'Самостійний, здатний використовувати всі прибори'),
            ScaleOption(score: 5.0, text: 'Потребує допомоги в нарізанні або намазуванні'),
            ScaleOption(score: 0.0, text: 'Повністю залежний від сторонніх'),
          ],
        ),
      ],
    ),
  ];

  static String interpretSingleRow(String scaleId, int score) {
    if (scaleId == 'rass') {
      if (score > 0) return "($score б.) — Наявність психомоторного збудження / ажитації.";
      if (score == 0) return "(0 б.) — Нормальний стан неспання, адекватна свідомість.";
      return "($score б.) — Пригнічення свідомості / медикаментозна седація.";
    }
    if (scaleId == 'ashworth') {
      if (score == 0) return "(0 б.) — М\'язовий тонус не змінений (норма).";
      if (score <= 2) return "($score б.) — Легка спастичність м\'язів.";
      if (score <= 4) return "($score б.) — Виражений гіпертонус, рух обмежений.";
      return "(5 б.) — Фіксована контрактура, пасивний рух неможливий.";
    }
    return "Оцінка зафіксована ($score балів)";
  }

  static Map<String, dynamic> calculateVitalsTest({
    required String testId,
    required int hrLying, required int sysLying, required int diaLying,
    required int hrStanding, required int sysStanding, required int diaStanding,
  }) {
    final deltaHr = hrStanding - hrLying;
    final deltaSys = sysLying - sysStanding;
    final deltaDia = diaLying - diaStanding;

    String diagnosis = "";
    int totalScore = 0;

    if (testId == 'orthostatic_test') {
      if (deltaSys >= 20 || deltaDia >= 10) {
        diagnosis = "Позитивна проба! Виражена Ортостатична Гіпотензія. Високий ризик синкопе.";
        totalScore = 2;
      } else if (deltaHr >= 30 && deltaSys < 20) {
        diagnosis = "Позитивна проба за тахікардіальним типом! Ознаки синдрому ПОТС (POTS).";
        totalScore = 1;
      } else {
        diagnosis = "Негативна проба (Норма). Серцево-судинна система адаптована.";
        totalScore = 0;
      }
    } else {
      if (deltaSys >= 20 && deltaHr < 10) {
        diagnosis = "Тілт-тест позитивний: Вазодепресорний варіант ортостатичної недостатності.";
        totalScore = 2;
      } else {
        diagnosis = "Тілт-тест негативний або в межах фізіологічної адаптації.";
        totalScore = 0;
      }
    }

    return {
      'score': totalScore,
      'text': "Δ ЧСС: +$deltaHr уд/хв, Падіння АТ: $deltaSys/$deltaDia мм рт.ст. Висновок: $diagnosis"
    };
  }
}
