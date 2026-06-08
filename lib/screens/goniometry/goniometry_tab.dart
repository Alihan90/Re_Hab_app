import 'package:flutter/material.dart';

class JointProfile {
  final String jointName;
  final String movementType;
  final int normalMin;
  final int normalMax;
  final String clinicalNote;

  JointProfile({
    required this.jointName,
    required this.movementType,
    required this.normalMin,
    required this.normalMax,
    required this.clinicalNote,
  });
}

class GoniometryTab extends StatefulWidget {
  const GoniometryTab({Key? key}) : super(key: key);

  @override
  State<GoniometryTab> createState() => _GoniometryTabState();
}

class _GoniometryTabState extends State<GoniometryTab> {
  // База анатомічних норм кутів суглобів згідно з клінічними рекомендаціями
  final List<JointProfile> _jointsDatabase = [
    JointProfile(jointName: 'Колінний суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 135, clinicalNote: 'Норма згинання забезпечує повноцінну фазу опору та перенесення ноги при ходьбі.'),
    JointProfile(jointName: 'Колінний суглоб', movementType: 'Екстензія (Розгинання)', normalMin: 0, normalMax: 0, clinicalNote: 'Дефіцит розгинання навіть у 5° спричиняє хронічне перевантаження квадрицепса та кульгавість.'),
    JointProfile(jointName: 'Ліктьовий суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 150, clinicalNote: 'Критично для самообслуговування (піднесення їжі до рота, гігієна).'),
    JointProfile(jointName: 'Плечовий суглоб', movementType: 'Абдукція (Відведення)', normalMin: 0, normalMax: 180, clinicalNote: 'Оцінює мобільність лопатки та функцію ротаторної манжети плеча.'),
    JointProfile(jointName: 'Плечовий суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 180, clinicalNote: 'Необхідно для дотягування пацієнта до верхніх полиць у побуті.'),
    JointProfile(jointName: 'Кульшовий суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 120, clinicalNote: 'Необхідно для фізіологічного сідання на стілець без компенсації попереком.'),
  ];

  int _selectedJointIndex = 0;
  double _measuredAngle = 90.0; // Поточний заміряний кут на кутомірі
  bool _isSensorSimulationActive = false;

  @override
  Widget build(BuildContext context) {
    final activeJoint = _jointsDatabase[_selectedJointIndex];
    
    // Розрахунок клінічного дефіциту амплітуди рухів
    int targetNormal = activeJoint.normalMax;
    double deficitDegrees = 0;
    double recoveryPercentage = 100;

    if (targetNormal > 0) {
      deficitDegrees = (targetNormal - _measuredAngle).clamp(0, targetNormal.toDouble());
      recoveryPercentage = ((_measuredAngle / targetNormal) * 100).clamp(0, 100);
    } else {
      // Для екстензії, де норма 0°, будь-який кут вище нуля — це дефіцит
      deficitDegrees = _measuredAngle;
      recoveryPercentage = _measuredAngle == 0 ? 100 : (100 - (_measuredAngle * 5)).clamp(0, 100);
    }

    // Визначення кольору статусу залежно від об\'єму рухів
    Color statusColor = Colors.green;
    String statusText = 'Функція збережена (Норма)';
    
    if (deficitDegrees > 30) {
      statusColor = Colors.red.shade700;
      statusText = 'Виражена суглобова контрактура / Блок рухів';
    } else if (deficitDegrees > 10) {
      statusColor = Colors.orange.shade700;
      statusText = 'Помірне обмеження амплітуди (ROM)';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Блок вибору суглоба
          const Text('Цільовий суглоб та тип локомоції:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: _selectedJointIndex,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            items: List.generate(_jointsDatabase.length, (index) {
              final item = _jointsDatabase[index];
              return DropdownMenuItem(
                value: index,
                child: Text('${item.jointName} — ${item.movementType}', style: const TextStyle(fontSize: 14)),
              );
            }),
            onChanged: (val) {
              setState(() {
                _selectedJointIndex = val!;
                // Скидаємо дефолтний кут під норму обраного суглоба для зручності
                _measuredAngle = _jointsDatabase[_selectedJointIndex].normalMax > 0 
                    ? (_jointsDatabase[_selectedJointIndex].normalMax * 0.7).roundToDouble() 
                    : 10.0;
              });
            },
          ),
          const SizedBox(height: 16),

          // Інформаційна медична довідка
          Card(
            color: Colors.blue.shade50,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Анатомічний орієнтир: Фізіологічна норма = ${activeJoint.normalMax}°',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(activeJoint.clinicalNote, style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.3)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Візуальний симулятор цифрового кутоміра
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: targetNormal > 0 ? _measuredAngle / targetNormal : 1.0 - (_measuredAngle / 90).clamp(0.0, 1.0),
                    strokeWidth: 14,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_measuredAngle.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.black)),
                    const Text('заміряний кут', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ручне налаштування кута (імітація закриття плеча гоніометра)
          Slider(
            value: _measuredAngle,
            min: 0,
            max: activeJoint.normalMax > 0 ? activeJoint.normalMax.toDouble() + 20 : 90,
            divisions: 180,
            label: '${_measuredAngle.toStringAsFixed(0)}°',
            onChanged: _isSensorSimulationActive ? null : (v) => setState(() => _measuredAngle = v.roundToDouble()),
          ),

          // Кнопка включення інтерактивного трекінгу
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSensorSimulationActive ? '🟢 Гіроскоп телефона активний' : '📱 Використати датчик нахилу',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _isSensorSimulationActive,
                onChanged: (val) {
                  setState(() {
                    _isSensorSimulationActive = val;
                    if (_isSensorSimulationActive) {
                      // Емуляція стабільного зняття даних з акселерометра/гіроскопа при прикладанні до кінцівки
                      _measuredAngle = activeJoint.normalMax > 0 ? (activeJoint.normalMax * 0.65).roundToDouble() : 15;
                    }
                  });
                },
              )
            ],
          ),
          const Divider(height: 32),

          // Клінічний аналіз результатів для карти пацієнта
          const Text('Клінічний аналіз амплітуди рухів:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text('Статус суглоба:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text(statusText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text('Дефіцит до повної норми:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text('${deficitDegrees.toStringAsFixed(0)}°', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: deficitDegrees > 0 ? Colors.red : Colors.green)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text('Обсяг збереженої функції:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text('${recoveryPercentage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade50, foregroundColor: Colors.teal.shade900),
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('Копіювати висновок у буфер для карти'),
            onPressed: () {
              final text = 'Проведено гоніометрію: ${activeJoint.jointName} (${activeJoint.movementType}). Заміряний кут: ${_measuredAngle.toStringAsFixed(0)}°. Дефіцит амплітуди: ${deficitDegrees.toStringAsFixed(0)}°. Збережено функції: ${recoveryPercentage.toStringAsFixed(0)}%. Статус: $statusText.';
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Клінічний висновок скопійовано! Його можна вставити в щоденник візиту.')),
              );
            },
          )
        ],
      ),
    );
  }
}
