import 'package:flutter/material.dart';
import 'package:re_hab_app/screens/home/home_screen.dart';
import 'package:re_hab_app/screens/scales/scales_screen.dart'; 
import 'package:re_hab_app/screens/exercises/exercises_screen.dart'; 
import 'package:re_hab_app/screens/settings/settings_screen.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('📊 Екран шкал (Тут буде 40+ шкал по нозологіях)')),
    const Center(child: Text('📐 Гоніометрія (Введення градусів та замір сенсорами)')),
    const Center(child: Text('🏋️ Комплекси вправ (Фізичні, апаратні, інвентар)')),
    const Center(child: Text('⚙️ Налаштування додатку (Теми, інтерфейс)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Пацієнти'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Шкали'),
          NavigationDestination(icon: Icon(Icons.architecture_outlined), selectedIcon: Icon(Icons.architecture), label: 'Гоніометрія'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Вправи'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Налаштування'),
        ],
      ),
    );
  }
}
