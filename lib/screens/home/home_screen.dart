import '../settings/settings_tab.dart';
import '../exercises/exercises_tab.dart';
import '../goniometry/goniometry_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../services/smart_irp_engine.dart';
import '../patients/add_patient_screen.dart';
import '../patients/patient_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rehabProvider = Provider.of<RehabProvider>(context);
    final activePatients = rehabProvider.patients.where((p) => p.isActive).toList();

    // Список екранів для нижньої навігації
    final List<Widget> _tabs = [
      // ВКЛАДКА 0: ПАЦІЄНТИ
      activePatients.isEmpty
          ? const Center(
              child: Text(
                'Активні картки відсутні.\nНатисніть "+", щоб створити нову.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: activePatients.length,
              itemBuilder: (context, index) {
                final patient = activePatients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(patient.fullName.isNotEmpty ? patient.fullName[0] : 'П'),
                    ),
                    title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Діагноз: ${patient.diagnosis}\nМКХ-10: ${patient.icdCode}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailsScreen(patient: patient),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      // ВКЛАДКА 1: ПОВНОФУНКЦІОНАЛЬНИЙ КАТАЛОГ ШКАЛ (Реалізовано)
      const ScalesTab(),

      // ВКЛАДКА 2: ГОНІОМЕТРІЯ (Плейсхолдер для наступних кроків)
      const GoniometryTab(),

      // ВКЛАДКА 3: ВПРАВИ ТА МЕТОДИКИ (Плейсхолдер для наступних кроків)
      const ExercisesTab(),

      // ВКЛАДКА 4: НАЛАШТУВАННЯ (Плейсхолдер)
      const SettingsTab(),
    ];

    final List<String> _titles = [
      'Реабілітація: Пацієнти',
      'Клінічні шкали та тести (42)',
      'Гоніометрія суглобів',
      'База вправ та фізіотерапії',
      'Налаштування системи'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        elevation: 2,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPatientScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Пацієнти'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Шкали'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Гоніометр'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Вправи'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Налаштування'),
        ],
      ),
    );
  }
}

// --- ІНТЕРАКТИВНИЙ МОДУЛЬ КЛІНІЧНИХ ШКАЛ ---
class ScalesTab extends StatefulWidget {
  const ScalesTab({Key? key}) : super(key: key);

  @override
  State<ScalesTab> createState() => _ScalesTabState();
}

class _ScalesTabState extends State<ScalesTab> {
  final SmartIrpEngine _engine = SmartIrpEngine();
  String _searchQuery = '';
  String _selectedCategory = 'Усі';
  String _selectedAge = 'Всі';

  @override
  Widget build(BuildContext context) {
    // Фільтрація каталогу шкал на основі критеріїв користувача
    final filteredScales = _engine.scalesCatalog.where((scale) {
      final matchesSearch = scale.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scale.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Усі' || scale.category == _selectedCategory;
      final matchesAge = _selectedAge == 'Всі' || scale.ageGroup == _selectedAge || scale.ageGroup == 'Всі';
      return matchesSearch && matchesCategory && matchesAge;
    }).toList();

    return Column(
      children: [
        // Панель пошуку та швидких фільтрів
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Пошук шкал (напр. Berg, Ashworth, GMFM)...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        // Горизонтальний фільтр за КАТЕГОРІЯМИ НОЗОЛОГІЙ
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: ['Усі', 'Неврологія', 'Педіатрія', 'Ортопедія', 'Загальні'].map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: Colors.blue.shade700,
                  checkmarkColor: Colors.white,
                  onSelected: (bool selected) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Горизонтальний фільтр за ВІКОВИМИ ГРУПАМИ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              const Text('Вік:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 12),
              ...['Всі', 'Дорослі', 'Діти'].map((age) {
                final isSelected = _selectedAge == age;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(age, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedAge = age);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const Divider(height: 10),

        // Результати пошуку та виводу медичних даних
        Expanded(
          child: filteredScales.isEmpty
              ? const Center(child: Text('За вказаними фільтрами шкал не знайдено.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filteredScales.length,
                  itemBuilder: (ctx, idx) {
                    final scale = filteredScales[idx];
                    
                    // Визначення кольору іконки залежно від напрямку медицини
                    Color categoryColor = Colors.grey;
                    IconData categoryIcon = Icons.assignment;
                    if (scale.category == 'Неврологія') {
                      categoryColor = Colors.purple;
                      categoryIcon = Icons.psychology;
                    } else if (scale.category == 'Педіатрія') {
                      categoryColor = Colors.orange;
                      categoryIcon = Icons.child_care;
                    } else if (scale.category == 'Ортопедія') {
                      categoryColor = Colors.red;
                      categoryIcon = Icons.accessibility_new;
                    } else if (scale.category == 'Загальні') {
                      categoryColor = Colors.teal;
                      categoryIcon = Icons.directions_walk;
                    }

                    return Card(
                      elevation: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: categoryColor.withOpacity(0.12),
                          child: Icon(categoryIcon, color: categoryColor, size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(scale.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                              child: Text(scale.ageGroup, style: TextStyle(fontSize: 9, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                            )
                          ],
                        ),
                        subtitle: Text(scale.fullName, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.analytics_outlined, size: 14, color: Colors.blueGrey),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Діапазон оцінювання: від ${scale.minScore.toStringAsFixed(0)} до ${scale.maxScore.toStringAsFixed(0)} балів',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Клінічна інтерпретація результатів:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      Text(scale.interpretation, style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.black87)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- ТИМЧАСОВІ СТРУКТУРНІ ПЛЕЙСХОЛДЕРИ ДЛЯ НАСТУПНИХ КРОКІВ ---

class _GoniometryTabPlaceholder extends StatelessWidget {
  const _GoniometryTabPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Замір амплітуди рухів (ROM):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          OutlinedButton.icon(icon: const Icon(Icons.screen_rotation), label: const Text('Виміряти за допомогою гіроскопа телефона'), onPressed: () {}),
          const SizedBox(height: 16),
          TextFormField(decoration: const InputDecoration(labelText: 'Кут згинання суглоба (градуси °)', border: OutlineInputBorder())),
        ],
      ),
    );
  }
}

class _ExercisesTabPlaceholder extends StatelessWidget {
  const _ExercisesTabPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(child: ListTile(leading: Icon(Icons.directions_run), title: Text('Кінезотерапія / Фізичні вправи'))),
        Card(child: ListTile(leading: Icon(Icons.fitness_center), title: Text('Тренажерні та механотерапевтичні методи'))),
        Card(child: ListTile(leading: Icon(Icons.bolt), title: Text('Електростимуляція та магнітотерапія'))),
        Card(child: ListTile(leading: Icon(Icons.handyman), title: Text('Заняття з реабілітаційним інвентарем'))),
      ],
    );
  }
}

class _SettingsTabPlaceholder extends StatelessWidget {
  const _SettingsTabPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(title: const Text('Темна тема інтерфейсу'), value: false, onChanged: (v) {}),
        ListTile(leading: const Icon(Icons.person), title: const Text('Профіль спеціаліста'), trailing: const Icon(Icons.chevron_right)),
        ListTile(leading: const Icon(Icons.storage), title: const Text('Резервне копіювання БД (Експорт)'), trailing: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
