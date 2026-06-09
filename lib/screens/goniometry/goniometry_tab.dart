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
    JointProfile(jointName: 'Колінний суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 135, clinicalNote: 'Норма згинання забезпечує повноцінну ходьбу.'),
    JointProfile(jointName: 'Колінний суглоб', movementType: 'Екстензія (Розгинання)', normalMin: 0, normalMax: 0, clinicalNote: 'Дефіцит розгинання спричиняє кульгавість.'),
    JointProfile(jointName: 'Ліктьовий суглоб', movementType: 'Флексія (Згинання)', normalMin: 0, normalMax: 150, clinicalNote: 'Критично для самообслуговування.'),
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

    Color statusColor = deficitDegrees > 10 ? Colors.orange : Colors.green;
    String statusText = deficitDegrees > 10 ? 'Обмеження амплітуди' : 'Норма';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedJointIndex,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: List.generate(_jointsDatabase.length, (index) {
              return DropdownMenuItem(value: index, child: Text(_jointsDatabase[index].jointName));
            }),
            onChanged: (val) => setState(() => _selectedJointIndex = val!),
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: recoveryPercentage / 100, strokeWidth: 10, valueColor: AlwaysStoppedAnimation<Color>(statusColor))),
                Text('${_measuredAngle.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Slider(
            value: _measuredAngle,
            min: 0, max: 180,
            onChanged: (v) => setState(() => _measuredAngle = v.roundToDouble()),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Статус:'), Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Дефіцит:'), Text('${deficitDegrees.toStringAsFixed(0)}°')]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Збережено функції:'), Text('${recoveryPercentage.toStringAsFixed(0)}%')]),
              ],
            ),
          )
        ],
      ),
    );
  }
}
