import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final isUk = provider.locale == 'uk';

    return Scaffold(
      appBar: AppBar(title: Text(isUk ? 'Налаштування' : 'Settings'), backgroundColor: Colors.teal),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(isUk ? 'Темна тема екрана' : 'Dark Mode Theme'),
            secondary: const Icon(Icons.brightness_6),
            value: provider.isDarkMode,
            activeColor: Colors.teal,
            onChanged: (val) => provider.toggleTheme(),
          ),
          ListTile(
            title: Text(isUk ? 'Мова додатка (Language)' : 'App Language'),
            subtitle: Text(isUk ? 'Українська' : 'English'),
            secondary: const Icon(Icons.language),
            trailing: DropdownButton<String>(
              value: provider.locale,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'uk', child: Text('UA')),
                DropdownMenuItem(value: 'en', child: Text('EN')),
              ],
              onChanged: (lang) {
                if (lang != null) provider.setLocale(lang);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(isUk ? 'Версія ПЗ' : 'App Version'),
            subtitle: const Text('1.0.0 (Release Build 2026)'),
            secondary: const Icon(Icons.info_outline),
          )
        ],
      ),
    );
  }
}
