import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
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

    // Список екранів для швидкого перемикання вкладок
    final List<Widget> _tabs = [
      // ВКЛАДКА 0: ПАЦІЄНТИ (Ваш оригінальний код)
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

      // ВКЛАДКА 1: ШКАЛИ (База оцінювання за нозологіями)
      const _ScalesTabPlaceholder(),

      // ВКЛАДКА 2: ГОНІОМЕТРІЯ (Вимірювання кутів)
      const _GoniometryTabPlaceholder(),

      // ВКЛАДКА 3: ВПРАВИ ТА МЕТОДИКИ (Фізичні, апаратні, інвентар)
      const _ExercisesTabPlaceholder(),

      // ВКЛАДКА 4: НАЛАШТУВАННЯ
      const _SettingsTabPlaceholder(),
    ];

    // Динамічні заголовки для AppBar залежно від обраної вкладки
    final List<String> _titles = [
      'Реабілітація: Пацієнти',
      'Клінічні шкали та тести',
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
          : null, // FAB відображається тільки на вкладці пацієнтів
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

// --- ТИМЧАСОВІ СТРУКТУРНІ ПЛЕЙСХОЛДЕРИ ДЛЯ ВЕНТИЛЯЦІЇ ДИЗАЙНУ ---

class _ScalesTabPlaceholder extends StatelessWidget {
  const _ScalesTabPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Сортування за віком та нозологіями (40+ шкал):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Card(child: ListTile(leading: const Icon(Icons.elderly), title: const Text('Неврологічні шкали (Дорослі)'), subtitle: const Text('Berg, NIHSS, Ashworth, Barthel...'))),
        Card(child: ListTile(leading: const Icon(Icons.child_care), title: const Text('Педіатричні шкали (Діти)'), subtitle: const Text('GMFM, WeeFIM, Alberta...'))),
        Card(child: ListTile(leading: const Icon(Icons.accessible), title: const Text('Ортопедія та Травматологія'), subtitle: const Text('DASH, WOMAC, KOOS, Harris...'))),
      ],
    );
  }
}

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
