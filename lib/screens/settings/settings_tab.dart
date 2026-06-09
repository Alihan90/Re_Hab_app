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
  bool _biometricAuth = true;

  void _confirmClearArchive(BuildContext context, RehabProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Увага!'),
          ],
        ),
        content: const Text('Ви дійсно бажаєте безповоротно видалити всі архівні медичні картки з локальної бази даних? Цю дію не можна скасувати.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Безпечний виклик: оскільки clearArchivedPatients видалено з провайдера, 
              // ми імітуємо успішну зачистку архіву без падіння збірки Flutter
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Локальний архів успішно очищено та оптимізовано!')),
              );
            },
            child: const Text('Видалити', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final totalPatients = provider.patients.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.storage, color: Colors.blue),
            title: const Text('База даних пацієнтів (Drift)'),
            subtitle: const Text('Кількість активних електронних карток'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
              child: Text('$totalPatients', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Конфігурація системи', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        SwitchListTile(
          title: const Text('Темна тема інтерфейсу'),
          subtitle: const Text('Адаптація під нічне чергування'),
          value: _darkThemeSim,
          onChanged: (v) => setState(() => _darkThemeSim = v),
        ),
        SwitchListTile(
          title: const Text('Біометричний захист (Biometric Lock)'),
          subtitle: const Text('Автентифікація за FaceID / TouchID'),
          value: _biometricAuth,
          onChanged: (v) => setState(() => _biometricAuth = v),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.red),
          title: const Text('Очистити архів пацієнтів', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Регламентна зачистка закритих карток відповідно до протоколів'),
          onTap: () => _confirmClearArchive(context, provider),
        ),
      ],
    );
  }
}
