import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final isUk = provider.locale == 'uk';

    final List<Map<String, String>> staticCatalog = [
      {
        'title': 'Дзеркальна терапія (Неврологія)',
        'desc': 'Синхронні рухи кистей перед дзеркалом для активації нейропластичності.',
        'dose': '15 хв, 2 рази на день'
      },
      {
        'title': 'Діафрагмальне дихання (Респіраторна)',
        'desc': 'Контроль дихання животом для збільшення вентиляції легень та SpO2.',
        'dose': '12 повторів, 3 серії щоденно'
      },
      {
        'title': 'Ізометрія квадрицепса (Ортопедія)',
        'desc': 'Статичне напруження м\'яза стегна для стабілізації колінного суглоба.',
        'dose': 'Утримання 6 сек, 15 повторень'
      }
    ];

    return Scaffold(
      appBar: AppBar(title: Text(isUk ? 'Каталог вправ та методик' : 'Exercise & Therapy Catalog'), backgroundColor: Colors.teal),
      body: ListView.builder(
        itemCount: staticCatalog.length,
        itemBuilder: (context, index) {
          final item = staticCatalog[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              style: ListTileStyle.list,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 4),
                  Text(item['desc']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${isUk ? 'Рекомендоване дозування' : 'Default dosage'}: ${item['dose']}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
