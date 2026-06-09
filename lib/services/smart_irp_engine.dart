import 'dart:math';

class SmartPlan {
  final String goalsSmart;
  final String mfkCodes; 
  final Map<int, List<ExerciseItem>> daysSchedule;

  SmartPlan({
    required this.goalsSmart,
    required this.mfkCodes,
    required this.daysSchedule,
  });
}

class ExerciseItem {
  final String title;
  final String category; 
  final String dosage;

  ExerciseItem({required this.title, required this.category, required this.dosage});
}

class ClinicalScale {
  final String id;
  final String name;
  final String fullName;
  final String category; 
  final String ageGroup; 
  final double minScore;
  final double maxScore;
  final String interpretation;

  ClinicalScale({
    required this.id,
    required this.name,
    required this.fullName,
    required this.category,
    required this.ageGroup,
    required this.minScore,
    required this.maxScore,
    required this.interpretation,
  });
}

class SmartIrpEngine {
  final List<ClinicalScale> scalesCatalog = [
    ClinicalScale(id: 'bbs', name: 'Berg Balance Scale', fullName: 'Шкала рівноваги Берга', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 56, interpretation: '0-20: високий ризик падінь; 21-40: прийнятний; 41-56: незалежність'),
    ClinicalScale(id: 'mas', name: 'Modified Ashworth Scale', fullName: 'Модифікована шкала Ашворта', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 5, interpretation: '0: тонус норма; 1-1+: легке підвищення; 2: помірне; 3: значне; 4: ригідність'),
    ClinicalScale(id: 'bi', name: 'Barthel Index', fullName: 'Індекс активності повсякденного життя Бартел', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 100, interpretation: '0-20: повна залежність; 21-60: тяжка; 61-90: помірна; 91-99: легка; 100: повна незалежність'),
    ClinicalScale(id: 'rmi', name: 'Rivermead Mobility Index', fullName: 'Індекс мобільності Рівермід', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 15, interpretation: 'Низький бал вказує на грубі порушення довільних рухів та неможливість пересування'),
    ClinicalScale(id: 'nihss', name: 'NIHSS', fullName: 'Шкала інсульту Національного інституту здоров\'я', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 42, interpretation: '0: ні; 1-4: легкий; 5-15: помірний; 16-20: середньо-тяжкий; 21-42: тяжкий інсульт'),
    ClinicalScale(id: 'fim', name: 'FIM (Functional Independence Measure)', fullName: 'Міра функціональної незалежності', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 18, maxScore: 126, interpretation: 'Оцінює моторну та когнітивну сфери self-care самостійності'),
    ClinicalScale(id: 'fma', name: 'Fugl-Meyer Assessment', fullName: 'Шкала Фугл-Мейєра для рухового відновлення', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 226, interpretation: 'Максимальний моторний бал: 100 (верхня кінцівка 66, нижня 34)'),
    ClinicalScale(id: 'tis', name: 'Trunk Impairment Scale', fullName: 'Шкала порушень функції тулуба', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 23, interpretation: 'Оцінка статичної, динамічної рівноваги тулуба та координації'),
    ClinicalScale(id: 'moca', name: 'MoCA', fullName: 'Монреальська шкала когнітивної оцінки', category: 'Н微рологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 30, interpretation: '26-30: норма; менше 26: когнітивні порушення/деменція'),
    ClinicalScale(id: 'mrs', name: 'Modified Rankin Scale', fullName: 'Модифікована шкала Ренкіна', category: 'Неврологія', ageGroup: 'Дорослі', minScore: 0, maxScore: 6, interpretation: '0: без симптомів; 1: без значної інвалідизації; 5: тяжка інвалідність; 6: смерть'),
    ClinicalScale(id: 'gmfm88', name: 'GMFM-88', fullName: 'Вимірювання великих моторних функцій (88 пунктів)', category: 'Педіатрія', ageGroup: 'Діти', minScore: 0, maxScore: 100, interpretation: 'Оцінка відсоткового виконання рухових завдань у 5 положеннях при ДЦП'),
    ClinicalScale(id: 'gmfcs', name: 'GMFCS', fullName: 'Система класифікації великих моторних функцій', category: 'Педіатрія', ageGroup: 'Діти', minScore: 1, maxScore: 5, interpretation: 'Рівень I: ходьба без обмежень; Рівень V: дитина не утримує голову і тулуб'),
    ClinicalScale(id: 'weefim', name: 'WeeFIM', fullName: 'Функціональна незалежність для дітей', category: 'Педіатрія', ageGroup: 'Діти', minScore: 18, maxScore: 126, interpretation: 'Педіатрична адаптація шкали FIM для оцінки життєдіяльності'),
    ClinicalScale(id: 'aims', name: 'AIMS (Alberta Infant Motor Scale)', fullName: 'Альбертська шкала моторного розвитку немовлят', category: 'Педіатрія', ageGroup: 'Діти', minScore: 0, maxScore: 58, interpretation: 'Оцінка рухового дозрівання дитини від народження до самостійної ходьби'),
    ClinicalScale(id: 'macs', name: 'MACS', fullName: 'Система класифікації мануальних здібностей дітей з ДЦП', category: 'Педіатрія', ageGroup: 'Діти', minScore: 1, maxScore: 5, interpretation: 'Рівень I: маніпулює предметами легко; Рівень V: обмеження тотальні'),
    ClinicalScale(id: 'pedi', name: 'PEDI', fullName: 'Опитувальник оцінки обмежень життєдіяльності у дітей', category: 'Педіатрія', ageGroup: 'Діти', minScore: 0, maxScore: 100, interpretation: 'Аналіз самообслуговування, мобільності та соціальної функції'),
    ClinicalScale(id: 'bfmf', name: 'BFMF', fullName: 'Класифікація білатеральної функції кисті', category: 'Педіатрія', ageGroup: 'Діти', minScore: 1, maxScore: 5, interpretation: 'Визначає ступінь ізольованого ураження кожної руки при гемі/діплегії'),
    ClinicalScale(id: 'quest', name: 'QUEST', fullName: 'Якісна оцінка навичок верхніх кінцівок', category: 'Педіатрія', ageGroup: 'Діти', minScore: 0, maxScore: 100, interpretation: 'Досліджує дисоційовані рухи, хвати, захисні реакції та вагу'),
    ClinicalScale(id: 'pdms2', name: 'Peabody Developmental Motor Scales', fullName: 'Розвиваючі моторні шкали Пібоді', category: 'Педіатрія', ageGroup: 'Діти', minScore: 0, maxScore: 400, interpretation: 'Раннє виявлення відставання тонкої та великої моторики'),
    ClinicalScale(id: 'edacs', name: 'EDACS', fullName: 'Система класифікації здібностей до їжі та пиття', category: 'Педіатрія', ageGroup: 'Діти', minScore: 1, maxScore: 5, interpretation: 'Рівень безпеки ковтання та незалежності під час їди'),
    ClinicalScale(id: 'dash', name: 'DASH Index', fullName: 'Недієздатність верхньої кінцівки (плече, лікоть, кисть)', category: 'Ортопедія', ageGroup: 'Всі', minScore: 0, maxScore: 100, interpretation: '0: ідеальна функція кінцівки; 100: maximal втрата працездатності'),
    ClinicalScale(id: 'womac', name: 'WOMAC Osteoarthritis Index', fullName: 'Індекс артриту університетів Західного Онтаріо та МакМастер', category: 'Ортопедія', ageGroup: 'Дорослі', minScore: 0, maxScore: 96, interpretation: 'Оцінка болю, скутості та funktionальних обмежень колінного/кульшового суглобів'),
    ClinicalScale(id: 'koos', name: 'KOOS', fullName: 'Шкала результатів травми та остеоартриту колінного суглоба', category: 'Ортопедія', ageGroup: 'Всі', minScore: 0, maxScore: 100, interpretation: '100: відсутність симптомів; 0: критичні проблеми з коліном'),
    ClinicalScale(id: 'hoos', name: 'HOOS', fullName: 'Шкала оцінки пошкоджень кульшового суглоба', category: 'Ортопедія', ageGroup: 'Всі', minScore: 0, maxScore: 100, interpretation: 'Розраховує профіль мобільності пацієнта після ендопротезування'),
    ClinicalScale(id: 'hhs', name: 'Harris Hip Score', fullName: 'Оцінка кульшового суглоба за Харрісом', category: 'Ортопедія', ageGroup: 'Дорослі', minScore: 0, maxScore: 100, interpretation: '<70: незадовільно; 70-79: задовільно; 80-89: добре; 90-100: відмінно'),
    ClinicalScale(id: 'amppro', name: 'AMPPRO', fullName: 'Amputee Mobility Predictor (з протезом)', category: 'Ортопедія', ageGroup: 'Дорослі', minScore: 0, maxScore: 47, interpretation: 'Прогнозування рівня мобільності K0-K4 для підбору комплектації протеза'),
    ClinicalScale(id: 'ampno', name: 'AMPnOP', fullName: 'Amputee Mobility Predictor (без протеза)', category: 'Ортопедія', ageGroup: 'Дорослі', minScore: 0, maxScore: 38, interpretation: 'Тестування рухового потенціалу кукси та здорової кінцівки до протезування'),
    ClinicalScale(id: 'spadi', name: 'SPADI', fullName: 'Індекс болю та недієздатності плечового суглоба', category: 'Ортопедія', ageGroup: 'Всі', minScore: 0, maxScore: 100, interpretation: 'Високий відсоток демонструє виражений больовий синдром та блок рухів'),
    ClinicalScale(id: 'lefs', name: 'Lower Extremity Functional Scale', fullName: 'Функціональна шкала нижніх кінцівок', category: 'Ортопедія', ageGroup: 'Всі', minScore: 0, maxScore: 80, interpretation: 'Максимум 80 означає повну відсутність утруднень у побуті та бігу'),
    ClinicalScale(id: 'vas', name: 'VAS Pain Scale', fullName: 'Візуально-аналогова шкала болю', category: 'Ортопедія', ageGroup: 'Всі', minScore: 0, maxScore: 10, interpretation: '0: болю немає; 1-3: слабкий; 4-6: помірний; 7-9: дуже сильний; 10: шоковий біль'),
    ClinicalScale(id: 'tug', name: 'Timed Up and Go (TUG)', fullName: 'Тест «Встань та йди» на час', category: 'Загальні', ageGroup: 'Всі', minScore: 0, maxScore: 60, interpretation: '<10 сек: норма; >13.5 сек: високий ризик падіння літніх осіб'),
    ClinicalScale(id: 'm6wt', name: '6-Minute Walk Test', fullName: '6-хвилинний тест ходьби', category: 'Загальні', ageGroup: 'Всі', minScore: 0, maxScore: 1000, interpretation: 'Вимірює толерантність до кардіореспіраторного навантаження в метрах'),
    ClinicalScale(id: 'fac', name: 'Functional Ambulation Categories', fullName: 'Категорії функціональної ходьби', category: 'Загальні', ageGroup: 'Дорослі', minScore: 0, maxScore: 5, interpretation: '0: не ходить; 3: ходить самостійно лише по рівній поверхні; 5: незалежна ходьба всюди'),
    ClinicalScale(id: 'borg', name: 'Borg RPE Scale', fullName: 'Шкала сприйняття навантаження Борга', category: 'Загальні', ageGroup: 'Всі', minScore: 6, maxScore: 20, interpretation: '6: стан спокою; 13: трохи важко; 19: вкрай важко; 20: максимальне виснаження'),
    ClinicalScale(id: 'dgi', name: 'Dynamic Gait Index', fullName: 'Динамічний індекс ходьби', category: 'Загальні', ageGroup: 'Дорослі', minScore: 0, maxScore: 24, interpretation: '<19 балів свідчить про високу схильність до травматизації під час ходьби'),
    ClinicalScale(id: 'sppb', name: 'SPPB', fullName: 'Короткий комплекс тестів фізичного стану', category: 'Загальні', ageGroup: 'Дорослі', minScore: 0, maxScore: 12, interpretation: 'Оцінка швидкості ходьби, балансу стоячи та 5 підйомів зі стільця'),
    ClinicalScale(id: 'tinetti', name: 'Tinetti POMA', fullName: 'Шкала оцінки рухової активності Тінетті', category: 'Загальні', ageGroup: 'Дорослі', minScore: 0, maxScore: 28, interpretation: '<19: високий ризик травм; 19-24: помірний ризик падіння'),
    ClinicalScale(id: 'eq5d', name: 'EuroQol (EQ-5D)', fullName: 'Опитувальник оцінки якості життя', category: 'Загальні', ageGroup: 'Всі', minScore: 0, maxScore: 1, interpretation: 'Показник загального благополуччя, мобільності, догляду, тривоги'),
    ClinicalScale(id: 'katz', name: 'Katz ADL Index', fullName: 'Індекс базової життєдіяльності Каца', category: 'Загальні', ageGroup: 'Дорослі', minScore: 0, maxScore: 6, interpretation: '6: повна збереженість функцій; 0: важкі обмеження самообслуговування'),
    ClinicalScale(id: 'lawton', name: 'Lawton IADL Scale', fullName: 'Шкала інструментальної активності Лоутона', category: 'Загальні', ageGroup: 'Дорослі', minScore: 0, maxScore: 8, interpretation: 'Оцінка здатності користуватися телефоном, транспортом, готувати, купувати'),
    ClinicalScale(id: 'fsst', name: 'Four Square Step Test', fullName: 'Тест кроку у чотирьох квадратах', category: 'Загальні', ageGroup: 'Всі', minScore: 0, maxScore: 30, interpretation: 'Оцінює динамічний баланс під час швидкої зміни вектору руху назад/вбік'),
    ClinicalScale(id: 'mrc', name: 'MRC Muscle Scale', fullName: 'Шкала оцінки сили м\'язів Медичної дослідницької ради', category: 'Загальні', ageGroup: 'Всі', minScore: 0, maxScore: 5, interpretation: '0: параліч; 1: сліди скорочення; 3: рух проти сили тяжіння; 5: нормальна сила'),
  ];

  final Map<String, String> icd10Database = {
    'Z89.2': 'Наявність ампутованої верхньої кінцівки (Протезування / кукса передпліччя)',
    'Z89.5': 'Наявність ампутованої нижньої кінцівки (Кукса гомілки / вище)',
    'I63.9': 'Інфаркт мозку неуточнений (Наслідки гострого ішемічного інсульту, геміпарез)',
    'G80.0': 'Спастичний церебральний параліч (ДЦП)',
    'M50.1': 'Ураження міжхребцевого диска шийного відділу з радикулопатією',
    'M51.1': 'Ураження міжхребцевих дисків поперекового відділу з радикулопатією (Кили / Грижі)',
    'M17.0': 'Первинний гонартроз двосторонній (Реабілітація після артропластики коліна)',
    'M16.0': 'Первинний коксартроз (Стан після ендопротезування кульшового суглоба)',
    'T08': 'Перелом хребта на неуточненому рівні (Наслідки хребетно-спинномозкової травми)',
    'G54.0': 'Ураження плечового сплетення (Плексит, парез верхньої кінцівки)',
    'S42.3': 'Перелом тіла плечової кістки (Посттравматична контрактура суглобів)',
    'T14.2': 'Перелом у неуточненій ділянці тіла (Стан після металоостеосинтезу кісток)',
  };

  SmartPlan generatePlan({required String icdCode, required String category}) {
    return autoGeneratePlan(
      mkh10Codes: [icdCode],
      age: 'Дорослі',
      plannedDays: 10,
      goalsSmart: 'Відновлення',
    );
  }

  SmartPlan autoGeneratePlan({
    required List<String> mkh10Codes,
    required String age,
    required int plannedDays,
    required String goalsSmart,
  }) {
    String selectedCode = mkh10Codes.isNotEmpty ? mkh10Codes.first : 'Невідомо';
    String smartResult = '';
    String mfkResult = '';
    List<ExerciseItem> baseExercises = [];

    if (selectedCode.toUpperCase().contains('Z89.2')) {
      smartResult = 
          '🎯 **S (Specific):** Навчання експлуатації та управлінню міоелектричним/тяговим протезом лівого передпліччя, відновлення дворучного симетричного хвату в побуті.\n'
          '📊 **M (Measurable):** Зниження індексу недієздатності за шкалою DASH до <25 балів, успішне виконання тесту SHAP (9 базових маніпуляцій з предметами).\n'
          '💪 **A (Achievable):** Робота з ерготерапевтом, спрямована активованість м\'язових тригерів кукси передпліччя за допомогою БОЗ-тренажерів.\n'
          '🏡 **R (Relevant):** Повне відновлення побутової незалежності: приготування їжі, застібання ґудзиків та блискавок без сторонньої допомоги.\n'
          '⏱️ **T (Time-bound):** Досягти стійкої адаптації до протеза протягом $plannedDays днів реабілітаційного циклу.';
      mfkResult = 'b730 (Функції м\'язової сили), b760 (Функції контролю довільних рухів), d445 (Використання точних рухів кисті з протезом), d5 (Самообслуговування).';
      baseExercises = [
        ExerciseItem(title: 'Дзеркальна терапія (Mirror Therapy) для подолання фантомного синдрому та стимуляції кори', category: 'Кінезотерапія', dosage: '20 хв, 2 рази на день'),
        ExerciseItem(title: 'Сенсорне насичення та десенсибілізація кукси передпліччя (масаж щітками, текстурами)', category: 'З інвентарем', dosage: '10 хв, перед заняттям'),
      ];
    } 
    else if (selectedCode.toUpperCase().contains('I63.9')) {
      smartResult = 
          '🎯 **S (Specific):** Збільшення амплітуди активних рухів у паретичних кінцівках, відновлення стереотипу вертикалізації та ізольованого кроку.\n'
          '📊 **M (Measurable):** Збільшення показника за шкалою Берга (BBS) на +8 балів, індексу Бартел до >75 балів (перехід у помірну залежність).\n'
          '💪 **A (Achievable):** Щоденні тренування за методиками PNF, Бобат-терапії та механотерапії на підвісних системах.\n'
          '🏡 **R (Relevant):** Здатність пацієнта самостійно сідати в ліжку та проходити до 50 метрів з триопорною палицею.\n'
          '⏱️ **T (Time-bound):** Реалізувати цілі за $plannedDays діб інтенсивного стаціонарного курсу.';
      mfkResult = 'b710 (Функції рухливості суглобів), b735 (Функції м\'язового тонусу), d410 (Зміна положення тіла), d450 (Ходьба).';
      baseExercises = [
        ExerciseItem(title: 'Полегшення рухів за концепцією Бобат та PNF-протоколи для паретичної сторони', category: 'Кінезотерапія', dosage: '40 хв, індивідуально'),
        ExerciseItem(title: 'Механотерапія на циклічному тренажері (типу Motomed) з функцією розпізнавання спастичності', category: 'Тренажерні методи', dosage: '20 хв, темп 30 об/хв'),
      ];
    } 
    else {
      smartResult = 
          '🎯 **S (Specific):** Ліквідація больового синдрому в ураженій ділянці, відновлення фізіологічного об\'єму рухів (ROM).\n'
          '📊 **M (Measurable):** Зниження болю за шкалою ВАШ до <=3 балів, збільшення кутів гоніометрії суглоба на 15-20°.\n'
          '💪 **A (Achievable):** Пасивна та активна розробка суглобів, застосування методик постізометричної релаксації (ПІР).\n'
          '🏡 **R (Relevant):** Відновлення базових локомоторних функцій, прибирання кульгавості або обмежень підйому руки.\n'
          '⏱️ **T (Time-bound):** Досягти результату за $plannedDays днів.';
      mfkResult = 'b280 (Відчуття болю), b710 (Рухливість суглобів), d450 (Ходьба / рух).';
      baseExercises = [
        ExerciseItem(title: 'Постізометрична релаксація (ПІР) та м\'які мануальні техніки мобілізації', category: 'Кінезотерапія', dosage: '25 хв'),
      ];
    }

    Map<int, List<ExerciseItem>> schedule = {};
    final random = Random();
    for (int day = 1; day <= plannedDays; day++) {
      schedule[day] = [baseExercises[random.nextInt(baseExercises.length)]];
    }

    return SmartPlan(
      goalsSmart: smartResult,
      mfkCodes: mfkResult,
      daysSchedule: schedule,
    );
  }
}
