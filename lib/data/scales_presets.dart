import '../models/clinical_models.dart';

class ScalesPresets {
  static final List<ClinicalScale> allScales = [
    // --- ОРТОПЕДІЯ ---
    ClinicalScale(id: 'odi', name: 'Індекс Освестрі (ODI)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 50, description: 'Оцінка болю в попереку.', sections: [
      ScaleSection(id: 'odi_1', title: 'Інтенсивність болю', options: [
        ScaleOption(score: 0, text: 'Біль не заважає'), ScaleOption(score: 1, text: 'Легкий'), ScaleOption(score: 2, text: 'Помірний'),
        ScaleOption(score: 3, text: 'Сильний'), ScaleOption(score: 4, text: 'Дуже сильний'), ScaleOption(score: 5, text: 'Нестерпний'),
      ]),
    ]),
    ClinicalScale(id: 'ndi', name: 'Індекс болю в шиї (NDI)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 50, description: 'Оцінка болю в шиї.', sections: [
      ScaleSection(id: 'ndi_1', title: 'Інтенсивність болю', options: [
        ScaleOption(score: 0, text: 'Відсутній'), ScaleOption(score: 1, text: 'Дуже легкий'), ScaleOption(score: 2, text: 'Помірний'),
        ScaleOption(score: 3, text: 'Досить сильний'), ScaleOption(score: 4, text: 'Дуже сильний'), ScaleOption(score: 5, text: 'Жахливий'),
      ]),
    ]),
    ClinicalScale(id: 'womac', name: 'WOMAC (Остеоартрит)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 96, description: 'Біль, скутість, функція.', sections: [
      ScaleSection(id: 'womac_pain', title: 'Біль', options: [
        ScaleOption(score: 0, text: 'Відсутній'), ScaleOption(score: 1, text: 'Легкий'), ScaleOption(score: 2, text: 'Помірний'),
        ScaleOption(score: 3, text: 'Сильний'), ScaleOption(score: 4, text: 'Екстремальний'),
      ]),
      ScaleSection(id: 'womac_stiff', title: 'Скутість', options: [
        ScaleOption(score: 0, text: 'Відсутня'), ScaleOption(score: 4, text: 'Екстремальна'),
      ]),
    ]),
    ClinicalScale(id: 'lequesne', name: 'Індекс Лекена', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 24, description: 'Функція суглобів.', sections: [
      ScaleSection(id: 'leq_pain', title: 'Біль', options: [
        ScaleOption(score: 0, text: 'Відсутній'), ScaleOption(score: 1, text: 'Мінімальний'), ScaleOption(score: 2, text: 'Помірний'), ScaleOption(score: 3, text: 'Сильний'),
      ]),
      ScaleSection(id: 'leq_dist', title: 'Дистанція ходьби', options: [
        ScaleOption(score: 0, text: '> 1 км'), ScaleOption(score: 1, text: '500-1000 м'), ScaleOption(score: 2, text: '300-500 м'), ScaleOption(score: 3, text: '< 300 м'),
      ]),
    ]),
    ClinicalScale(id: 'koos', name: 'KOOS (Коліно)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 100, description: 'Оцінка колінного суглоба.', sections: [
      ScaleSection(id: 'koos_symptoms', title: 'Симптоми', options: [
        ScaleOption(score: 0, text: 'Ніколи'), ScaleOption(score: 1, text: 'Рідко'), ScaleOption(score: 2, text: 'Іноді'), ScaleOption(score: 3, text: 'Часто'), ScaleOption(score: 4, text: 'Постійно'),
      ]),
      ScaleSection(id: 'koos_pain', title: 'Біль', options: [
        ScaleOption(score: 0, text: 'Ніколи'), ScaleOption(score: 4, text: 'Постійно'),
      ]),
    ]),
    ClinicalScale(id: 'hoos', name: 'HOOS (Кульшовий суглоб)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 100, description: 'Оцінка кульшового суглоба.', sections: [
      ScaleSection(id: 'hoos_pain', title: 'Біль', options: [
        ScaleOption(score: 0, text: 'Ніколи'), ScaleOption(score: 1, text: 'Рідко'), ScaleOption(score: 2, text: 'Іноді'), ScaleOption(score: 3, text: 'Часто'), ScaleOption(score: 4, text: 'Постійно'),
      ]),
      ScaleSection(id: 'hoos_adl', title: 'Активність', options: [
        ScaleOption(score: 0, text: 'Ніколи'), ScaleOption(score: 4, text: 'Постійно'),
      ]),
    ]),
    ClinicalScale(id: 'dash', name: 'DASH (Верхня кінцівка)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 100, description: 'Функція кінцівки.', sections: [
      ScaleSection(id: 'dash_main', title: 'Функціональна здатність', options: [
        ScaleOption(score: 1, text: 'Відсутні труднощі'), ScaleOption(score: 2, text: 'Легкі'), ScaleOption(score: 3, text: 'Помірні'),
        ScaleOption(score: 4, text: 'Значні'), ScaleOption(score: 5, text: 'Нездатність виконати'),
      ]),
    ]),
    ClinicalScale(id: 'constant_murley', name: 'Константа-Мурлі', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 100, description: 'Плечовий суглоб.', sections: [
      ScaleSection(id: 'cm_pain', title: 'Біль', options: [
        ScaleOption(score: 0, text: 'Сильний'), ScaleOption(score: 5, text: 'Помірний'), ScaleOption(score: 10, text: 'Легкий'), ScaleOption(score: 15, text: 'Відсутній'),
      ]),
    ]),
    ClinicalScale(id: 'tapes_r', name: 'TAPES-R', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 100, description: 'Після ампутації.', sections: [
      ScaleSection(id: 'tapes_psych', title: 'Психосоціальний стан', options: [
        ScaleOption(score: 1, text: 'Повністю не згоден'), ScaleOption(score: 2, text: 'Не згоден'), ScaleOption(score: 3, text: 'Згоден'), ScaleOption(score: 4, text: 'Повністю згоден'),
      ]),
    ]),
    ClinicalScale(id: 'amp', name: 'Індекс мобільності AMP', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 43, description: 'Мобільність з протезом.', sections: [
      ScaleSection(id: 'amp_task', title: 'Виконання завдання', options: [
        ScaleOption(score: 0, text: 'Не може'), ScaleOption(score: 1, text: 'З допомогою'), ScaleOption(score: 2, text: 'Самостійно'),
      ]),
    ]),
    ClinicalScale(id: 'fes_i', name: 'Страх падіння (FES-I)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 64, description: 'Ризик падіння.', sections: [
      ScaleSection(id: 'fes_item', title: 'Оцінка впевненості', options: [
        ScaleOption(score: 1, text: 'Не турбуюсь'), ScaleOption(score: 2, text: 'Трохи'), ScaleOption(score: 3, text: 'Досить'), ScaleOption(score: 4, text: 'Дуже'),
      ]),
    ]),
    ClinicalScale(id: 'ffi', name: 'Функція стопи (FFI)', category: 'Ортопедія', type: ScaleType.multiItem, maxRawScore: 100, description: 'Оцінка стопи.', sections: [
      ScaleSection(id: 'ffi_pain', title: 'Біль', options: [
        ScaleOption(score: 0, text: 'Відсутній'), ScaleOption(score: 10, text: 'Максимальний'),
      ]),
    ]),

    // --- КАРДІО-РЕСПІРАТОРНА ---
    ClinicalScale(id: 'mmrc', name: 'Задишка mMRC', category: 'Кардіо', type: ScaleType.selectRow, maxRawScore: 4, description: 'Рівень задишки.', sections: [
      ScaleSection(id: 'mmrc_grade', title: 'Ступінь', options: [
        ScaleOption(score: 0, text: '0: Тільки при важкому навантаженні'), ScaleOption(score: 1, text: '1: Швидка ходьба'),
        ScaleOption(score: 2, text: '2: Повільніша ходьба'), ScaleOption(score: 3, text: '3: 100 метрів'), ScaleOption(score: 4, text: '4: Спокій'),
      ]),
    ]),
    ClinicalScale(id: 'borg', name: 'Шкала Борга', category: 'Кардіо', type: ScaleType.selectRow, maxRawScore: 10, description: 'Інтенсивність.', sections: [
      ScaleSection(id: 'borg_score', title: 'Відчуття', options: [
        ScaleOption(score: 0, text: '0: Відсутнє'), ScaleOption(score: 3, text: '3: Помірне'), ScaleOption(score: 10, text: '10: Максимальне'),
      ]),
    ]),
    ClinicalScale(id: 'mwt6', name: 'Тест 6-хвилинної ходьби', category: 'Кардіо', type: ScaleType.vitalsProtocol, maxRawScore: 1000, description: 'Відстань (м).', sections: [
      ScaleSection(id: 'mwt6_dist', title: 'Дистанція', options: []),
    ]),
    ClinicalScale(id: 'shuttle_walk', name: 'Шатл-тест', category: 'Кардіо', type: ScaleType.vitalsProtocol, maxRawScore: 100, description: 'Рівні.', sections: [
      ScaleSection(id: 'sw_levels', title: 'Рівні', options: []),
    ]),
    ClinicalScale(id: 'sgrq', name: 'SGRQ (Якість життя)', category: 'Кардіо', type: ScaleType.multiItem, maxRawScore: 100, description: 'Респіраторна.', sections: [
      ScaleSection(id: 'sgrq_all', title: 'Оцінка', options: [ScaleOption(score: 0, text: 'Ні'), ScaleOption(score: 1, text: 'Так')]),
    ]),
    ClinicalScale(id: 'crq', name: 'CRQ (Легені)', category: 'Кардіо', type: ScaleType.multiItem, maxRawScore: 112, description: 'Симптоми.', sections: [
      ScaleSection(id: 'crq_all', title: 'Оцінка', options: [ScaleOption(score: 1, text: 'Найгірше'), ScaleOption(score: 7, text: 'Найкраще')]),
    ]),
    ClinicalScale(id: 'cat', name: 'CAT-тест (ХОЗЛ)', category: 'Кардіо', type: ScaleType.multiItem, maxRawScore: 40, description: 'Вплив ХОЗЛ.', sections: [
      ScaleSection(id: 'cat_all', title: '8 питань', options: [ScaleOption(score: 0, text: 'Немає проблем'), ScaleOption(score: 5, text: 'Максимум')]),
    ]),
    ClinicalScale(id: 'nyha', name: 'NYHA (Серце)', category: 'Кардіо', type: ScaleType.selectRow, maxRawScore: 4, description: 'Серце', sections: [
      ScaleSection(id: 'n_class', title: 'Клас', options: [
        ScaleOption(score: 1, text: 'I'), ScaleOption(score: 2, text: 'II'), ScaleOption(score: 3, text: 'III'), ScaleOption(score: 4, text: 'IV'),
      ]),
    ]),
    ClinicalScale(id: 'mlhfq', name: 'MLHFQ (Серце)', category: 'Кардіо', type: ScaleType.multiItem, maxRawScore: 105, description: 'Життя', sections: [
      ScaleSection(id: 'mlhfq_all', title: '21 питання', options: [ScaleOption(score: 0, text: 'Не впливає'), ScaleOption(score: 5, text: 'Максимально')]),
    ]),
    // --- КОГНІТИВНА ---
    ClinicalScale(id: 'mmse', name: 'MMSE', category: 'Когнітивна', type: ScaleType.multiItem, maxRawScore: 30, description: 'Статус', sections: [
      ScaleSection(id: 'm_orient', title: 'Орієнтація', options: [ScaleOption(score: 0, text: 'Помилка'), ScaleOption(score: 1, text: 'Правильно')]),
    ]),
    ClinicalScale(id: 'moca', name: 'MoCA', category: 'Когнітивна', type: ScaleType.multiItem, maxRawScore: 30, description: 'Порушення', sections: [
      ScaleSection(id: 'moca_all', title: 'Виконання', options: [ScaleOption(score: 0, text: 'Помилка'), ScaleOption(score: 1, text: 'Правильно')]),
    ]),
  ];
}
