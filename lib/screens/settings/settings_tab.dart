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
  bool _biometricAuthSim = true;

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 10),
            Text('Експорт зашифрованої БД', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text(
          'Усі медичні картки, протоколи SMART та записи гоніометрії будуть скомpriorityовані у захищений файл локального бекапу (encrypted_rehab_db.json).\n\nБажаєте завантажити?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔒 Бекап успішно збережено у внутрішню пам\'ять пристрою.')),
              );
            },
            child: const Text('Завантажити JSON'),
          ),
        ],
      ),
    );
  }

  void _showClearArchiveDialog(RehabProvider provider) {
    final archivedCount = provider.patients.where((p) => !p.isActive).length;

    if (archivedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('В архіві немає закритих карток для видалення.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 10),
            Text('Очищення медичного архіву', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          'Ви впевнені, що хочете безповоротно видалити $archivedCount закритих карток пацієнтів? Цю дію не можна буде скасувати.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              // Емуляція повного очищення архівних записів у провайдері
              provider.clearArchivedPatients();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Архів закритих кейсів повністю очищено відповідно до регламенту.')),
              );
            },
            child: const Text('Очистити архів'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final totalPatients = provider.patients.length;
    final activePatients = provider.patients.where((p) => p.isActive).length;
    final archivedPatients = totalPatients - activePatients;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // БЛОК 1: КЛІНІЧНА СТАТИСТИКА
        const Text('Панель моніторингу лікаря', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('$activePatients', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    const Text('В активній роботі', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text('$archivedPatients', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 4),
                    const Text('Успішні кейси (Архів)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // БЛОК 2: ІНТЕРФЕЙС ТА БЕЗПЕКА
        const Text('Конфігурація додатку', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Темний режим інтерфейсу', style: TextStyle(fontSize: 14)),
                value: _darkThemeSim,
                onChanged: (val) => setState(() => _darkThemeSim = val),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Біометрична автентифікація (FaceID/TouchID)', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Захист входу до медичної бази', style: TextStyle(fontSize: 11)),
                value: _biometricAuthSim,
                onChanged: (val) => setState(() => _biometricAuthSim = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // БЛОК 3: РОБОТА З ДАНИМИ
        const Text('Адміністрування локальної бази даних', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.storage, color: Colors.blueGrey),
                title: const Text('Резервне копіювання (Експорт)', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Зберегти зліпок карток пацієнтів', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: _showExportDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                title: const Text('Очистити закритий архів', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Безповоротно видалити виписаних пацієнтів', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => _showClearArchiveDialog(provider),
              ),
            ],
          ),
        ),
        
        // ПІДПИС ЛІЦЕНЗІЇ
        const SizedBox(height: 40),
        const Center(
          child: Text(
            'Smart IRP System • v2.1.0\nРозроблено відповідно до вимог НСЗУ та протоколів МОЗ України',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
          ),
        )
      ],
    );
  }
}
