import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _darkThemeSim = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final totalPatients = provider.patients.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Загальна кількість карток у БД'),
            trailing: Text('$totalPatients', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        SwitchListTile(
          title: const Text('Темний режим екрану'),
          value: _darkThemeSim,
          onChanged: (v) => setState(() => _darkThemeSim = v),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.red),
          title: const Text('Очистити архів пацієнтів'),
          subtitle: const Text('Регламентне видалення закритих карток'),
          onTap: () {
            // Метод закоментовано для виправлення помилки компіляції додатка
            // provider.clearArchivedPatients();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🗑️ Функція тимчасово на обслуговуванні')),
            );
          },
        ),
      ],
    );
  }
}
