import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rehabProvider = Provider.of<RehabProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування системи'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Перемикач теми інтерфейсу
          SwitchListTile(
            title: const Text('Темний режим інтерфейсу'),
            subtitle: const Text('Адаптація екрана для зменшення втоми очей'),
            value: rehabProvider.isDarkMode,
            secondary: const Icon(Icons.brightness_6),
            onChanged: (bool value) {
              // Виправлено: викликаємо метод без передачі аргументу value
              rehabProvider.toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Мова додатка'),
            subtitle: const Text('Українська (Системна)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Майбутня логіка локалізації
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Про медичний конструктор'),
            subtitle: const Text('Версія 1.0.0 (Реліз)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Re_Hab_app',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Розроблено для клінічної реабілітації.',
              );
            },
          ),
        ],
      ),
    );
  }
}
