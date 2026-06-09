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
  final List<JointProfile> _jointsDatabase = [
    JointProfile(jointName: 'Колінний суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 135, clinicalNote: 'Норма згинання забезпечує повноцінну фазу переносу ноги під час ходьби.'),
    JointProfile(jointName: 'Колінний суглоб', movementType: 'Екстензія (Розгинання)', normalMin: 0, normalMax: 0, clinicalNote: 'Дефіцит розгинання навіть на 5° спричиняє значну кульгавість.'),
    JointProfile(jointName: 'Ліктьовий суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 150, clinicalNote: 'Обмеження критично впливає на здатність до самообслуговування (їда, гігієна).'),
    JointProfile(jointName: 'Кульшовий суглоб', movementType: 'Абдукція (Відведення)', normalMin: 0, normalMax: 45, clinicalNote: 'Важливо для стабільності таза при одноопорній фазі кроку.'),
  ];

  int _selectedJointIndex = 0;
  double _measuredAngle = 90.0;
  bool _isSensorSimulationActive = false;

  @override
  Widget build(BuildContext context) {
    final activeJoint = _jointsDatabase[_selectedJointIndex];
    int targetNormal = activeJoint.normalMax;
    double deficitDegrees = targetNormal > 0 ? (targetNormal - _measuredAngle).clamp(0, targetNormal.toDouble()) : _measuredAngle;
    double recoveryPercentage = targetNormal > 0 ? ((_measuredAngle / targetNormal) * 100).clamp(0, 100) : 100;

    Color statusColor = deficitDegrees > 15 ? Colors.red : (deficitDegrees > 5 ? Colors.orange : Colors.green);
    String statusText = deficitDegrees > 15 ? 'Значний блок' : (deficitDegrees > 5 ? 'Помірний дефіцит' : 'Фізіологічна норма');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedJointIndex,
            decoration: const InputDecoration(labelText: 'Цільовий суглоб та тип руху', border: OutlineInputBorder()),
            items: List.generate(_jointsDatabase.length, (index) {
              return DropdownMenuItem(value: index, child: Text('${_jointsDatabase[index].jointName} - ${_jointsDatabase[index].movementType}'));
            }),
            onChanged: (val) => setState(() => _selectedJointIndex = val!),
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160, height: 160,
                  child: CircularProgressIndicator(
                    value: recoveryPercentage / 100, 
                    strokeWidth: 12, 
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                // Виправлено: заміна неіснуючого FontWeight.black на екстремальний товстий FontWeight.w900
                Text('${_measuredAngle.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _measuredAngle,
            min: 0, max: 180,
            divisions: 180,
            label: '${_measuredAngle.toStringAsFixed(0)}°',
            onChanged: _isSensorSimulationActive ? null : (v) => setState(() => _measuredAngle = v.roundToDouble()),
          ),
          SwitchListTile(
            title: const Text('Емуляція Bluetooth-гоніометра'),
            subtitle: const Text('Отримання кута нахилу в реальному часі з датчика'),
            value: _isSensorSimulationActive,
            onChanged: (v) => setState(() => _isSensorSimulationActive = v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Виправлено скрізь: `spaceBetween` замість помилкового `between`
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Клінічний статус:', style: TextStyle(fontWeight: FontWeight.bold)), Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Нормативне значення:'), Text('$targetNormal°')]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Поточний дефіцит рухливості:'), Text('${deficitDegrees.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.red))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Відсоток біомеханічного відновлення:'), Text('${recoveryPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                const Divider(height: 24),
                Text('💡 Примітка: ${activeJoint.clinicalNote}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
