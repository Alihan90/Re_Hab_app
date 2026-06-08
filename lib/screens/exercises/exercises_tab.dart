import 'package:flutter/material.dart';

class RehabExercise {
  final String title;
  final String category;
  final String description;
  final String dosage;
  final String precautions;

  RehabExercise({
    required this.title,
    required this.category,
    required this.description,
    required this.dosage,
    required this.precautions,
  });
}

class ExercisesTab extends StatefulWidget {
  const ExercisesTab({Key? key}) : super(key: key);

  @override
  State<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<ExercisesTab> {
  String _searchQuery = '';
  String _selectedCategory = 'Усі';

  // Базова клінічна база вправ та фізіотерапевтичних процедур
  final List<RehabExercise> _exercisesDatabase = [
    RehabExercise(
      title: 'Дзеркальна терапія (Mirror Therapy)',
      category: 'Кінезотерапія',
      description: 'Візуальна фантомна стимуляція кори головного мозку за допомогою дзеркала. Пацієнт виконує рухи здоровою рукою, дивлячись у дзеркало, що стимулює пластичність моторної кори ураженої півкулі.',
      dosage: '15-20 хвилин на сесію, 2 рази на день. Темп повільний, без перевтоми.',
      precautions: '⚠️ Припинити при виникненні запаморочення, вираженого фантомного болю або когнітивного перевантаження.',
    ),
    RehabExercise(
      title: 'ТЕНС (Черезшкірна електронейростимуляція)',
      category: 'Апаратна фізіо',
      description: 'Вплив імпульсними струмами низької частоти на м\'язи кукси або уражену кінцівку для купірування больового синдрому та підготовки м\'язів до рухової активності.',
      dosage: 'Частота 80-100 Гц, тривалість 15-20 хвилин. Курс 10 сесій.',
      precautions: '⚠️ Протипоказано при наявності кардіостимулятора, гострих запальних процесів у зоні накладання електродів.',
    ),
    RehabExercise(
      title: 'Ерготерапія: Циліндричний та щипковий хват',
      category: 'Інвентар & Ерго',
      description: 'Розробка дрібної моторики з використанням конусів, кілків або текстурних м\'ячиків. Моделювання побутових рухів (відкривання дверей, тримання чашки).',
      dosage: '3 підходи по 10 повторень для кожного типу хвату. Щодня.',
      precautions: '⚠️ Контролювати симетричність руху, уникати патологічних синкінезій (співдружніх рухів у інших частинах тіла).',
    ),
    RehabExercise(
      title: 'Магнітотерапія на область рубця/кукси',
      category: 'Апаратна фізіо',
      description: 'Вплив низькочастотним змінним магнітним полем для покращення мікроциркуляції, зниження набряку та прискорення регенерації м\'яких тканин після ампутації.',
      dosage: 'Інтенсивність 15-20 мТл, тривалість 12-15 хвилин. Щодня.',
      precautions: '⚠️ Протипоказано при схильності до кровотеч, системних захворюваннях крові, онкології.',
    ),
    RehabExercise(
      title: 'Пасивна розробка суглобів на CPM-апаратах',
      category: 'Механотерапія',
      description: 'Безперервний пасивний рух кінцівки за допомогою роботизованих шин для профілактики суглобових контрактур у ранньому періоді реабілітації.',
      dosage: 'Починаючи з 20-30° збільшуючи амплітуду на 5° щодня. Сесія 30 хвилин.',
      precautions: '⚠️ Не застосовувати при нестабільній фіксації перелому або гострому тромбофлебіті.',
    ),
    RehabExercise(
      title: 'Пропріоцептивне тренування на баланс-платформі',
      category: 'Інвентар & Ерго',
      description: 'Вправи на нестабільній подушці (балансирі) для відновлення глибокої чутливості, координації та активації м\'язів-стабілізаторів кора та нижніх кінцівок.',
      dosage: '3 серії по 2 хвилини утримання рівноваги з підтримкою або без.',
      precautions: '⚠️ Постійна страхівка терапевтом ззаду/збоку для виключення ризику падіння пацієнта.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Фільтрація бази вправ
    final filteredExercises = _exercisesDatabase.where((ex) {
      final matchesSearch = ex.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ex.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Усі' || ex.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      children: [
        // Панель пошуку вправ
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Пошук вправ чи фізіопроцедур...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        // Швидкі фільтри категорій
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: ['Усі', 'Кінезотерапія', 'Механотерапія', 'Апаратна фізіо', 'Інвентар & Ерго'].map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 8),

        // Список вправ
        Expanded(
          child: filteredExercises.isEmpty
              ? const Center(child: Text('У цій категорії вправ поки не знайдено.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filteredExercises.length,
                  itemBuilder: (ctx, idx) {
                    final exercise = filteredExercises[idx];

                    // Колірне кодування категорії
                    Color cardThemeColor = Colors.blueGrey;
                    if (exercise.category == 'Кінезотерапія') cardThemeColor = Colors.green;
                    if (exercise.category == 'Механотерапія') cardThemeColor = Colors.blue;
                    if (exercise.category == 'Апаратна фізіо') cardThemeColor = Colors.red;
                    if (exercise.category == 'Інвентар & Ерго') cardThemeColor = Colors.amber.shade800;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ExpansionTile(
                        leading: Icon(Icons.fitness_center_rounded, color: cardThemeColor),
                        title: Text(exercise.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(exercise.category, style: TextStyle(fontSize: 11, color: cardThemeColor, fontWeight: FontWeight.w600)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                const Text('📝 Біомеханіка та опис методики:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                                const SizedBox(height: 4),
                                Text(exercise.description, style: const TextStyle(fontSize: 13, height: 1.3)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.speed, size: 14, color: Colors.teal),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text('Клінічне дозування: ${exercise.dosage}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade100)),
                                  child: Text(exercise.precautions, style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }
}
