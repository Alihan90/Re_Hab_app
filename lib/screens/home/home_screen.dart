import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../patients/patients_screen.dart';
import '../scales/scales_screen.dart';
import '../exercises/exercises_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = [
    const PatientsScreen(),
    const ScalesScreen(),
    const ExercisesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final isUk = provider.locale == 'uk';

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.accessible_forward),
            label: isUk ? 'Пацієнти' : 'Patients',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_turned_in),
            label: isUk ? 'Шкали' : 'Scales',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: isUk ? 'Вправи' : 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: isUk ? 'Налаштування' : 'Settings',
          ),
        ],
      ),
    );
  }
}
