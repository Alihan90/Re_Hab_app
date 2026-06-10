import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../services/smart_irp_engine.dart';

class PatientDetailsScreen extends StatefulWidget {
  final dynamic patient; // Приймає об'єкт пацієнта з бази даних Drift

  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Множина для збереження номерів виконаних днів (наприклад, {1, 2, 5})
  final Set<int> _completedDays = <int>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Допоміжний метод розрахунку віку пацієнта
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    // Динамічно генеруємо SMART-план за допомогою нашого автономного рушія
    final irpPlan = SmartIrpEngine.generate(
      icdCode: widget.patient.icdCode,
      diagnosis: widget.patient.diagnosis,
      treatmentDays: widget.patient.treatmentDays ?? 10,
      complaints: widget.patient.complaints,
      expectations: widget.patient.expectations,
    );

    final totalDays = widget.patient.treatmentDays ?? 10;
    final progressPercentage = totalDays > 0 ? (_completedDays.length / totalDays) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Клінічний профіль'),
            Tab(icon: Icon(Icons.fact_check), text: 'Календар ІРП'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Елемент 1: Верхня інформаційна панель пацієнта + Прогрес-бар
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cake, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Вік: ${_calculateAge(widget.patient.dateOfBirth)} років',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Chip(
                      label: Text(widget.patient.icdCode),
                      backgroundColor: Colors.blue.shade100,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Виконання протоколу реабілітації:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('${(_completedDays.length)} / $totalDays дн. (${(progressPercentage * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // Елемент 2: Контент вкладок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ВКЛАДКА 1: КЛІНІЧНИЙ ПРОФІЛЬ ТА SMART
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionCard(
                      title: 'Офіційний клінічний діагноз',
                      icon: Icons.medical_services,
                      content: widget.patient.diagnosis,
                      iconColor: Colors.redAccent,
                    ),
                    if (widget.patient.complaints != null)
                      _buildSectionCard(
                        title: 'Анамнестичні скарги пацієнта',
                        icon: Icons.comment,
                        content: widget.patient.complaints!,
                        iconColor: Colors.orange,
                      ),
                    _buildSectionCard(
                      title: '⚠️ Клінічні застереження та моніторинг',
                      icon: Icons.warning_amber_rounded,
                      content: irpPlan.clinicalPrecautions,
                      iconColor: Colors.amber.shade900,
                      isAlert: true,
                    ),
                    _buildSectionCard(
                      title: 'Автоматичний SMART-критерій цілей',
                      icon: Icons.track_changes,
                      content: irpPlan.smartGoals,
                      iconColor: Colors.green,
                    ),
                  ],
                ),

                // ВКЛАДКА 2: ЩОДЕННИЙ ГРАФІК ТА ЧЕК-ЛІСТ
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: irpPlan.dailyActivities.length,
                  itemBuilder: (context, index) {
                    final dayNumber = index + 1;
                    final isDone = _completedDays.contains(dayNumber);
                    final activityText = irpPlan.dailyActivities[index];

                    // Очищаємо технічний префікс "День X — " для красивого відображення в картці
                    final displayBody = activityText.replaceFirst('День $dayNumber — ', '');

                    return Card(
                      elevation: isDone ? 1 : 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDone ? Colors.green.withOpacity(0.5) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      color: isDone ? Colors.green.shade50.withOpacity(0.6) : null,
                      child: CheckboxListTile(
                        activeColor: Colors.green,
                        title: Text(
                          'ДЕНЬ $dayNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.green.shade800 : Colors.blueGrey.shade800,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            displayBody,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDone ? Colors.grey : Colors.black87,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        value: isDone,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _completedDays.add(dayNumber);
                            } else {
                              _completedDays.remove(dayNumber);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Універсальний віджет картки для відображення структурованих медичних блоків
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    required Color iconColor,
    bool isAlert = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isAlert ? Colors.amber.shade50.withOpacity(0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isAlert ? Colors.amber.shade900 : null),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.4, leadingDistribution: TextLeadingDistribution.proportional),
            ),
          ],
        ),
      ),
    );
  }
}
