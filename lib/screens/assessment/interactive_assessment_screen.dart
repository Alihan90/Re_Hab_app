import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clinical_models.dart';
import '../../data/repositories/clinical_repository.dart';
import '../../providers/rehab_provider.dart';

class InteractiveAssessmentScreen extends StatefulWidget {
  final String patientId;
  final String scaleType; // 'berg' або 'barthel'

  const InteractiveAssessmentScreen({
    Key? key,
    required this.patientId,
    required this.scaleType,
  }) : super(key: key);

  @override
  State<InteractiveAssessmentScreen> createState() => _InteractiveAssessmentScreenState();
}

class _InteractiveAssessmentScreenState extends State<InteractiveAssessmentScreen> {
  // Мапа для збереження обраних балів: { itemId: selectedScore }
  final Map<int, int> _selectedScores = {};
  
  late List<ScaleItem> _scaleItems;
  late String _scaleName;

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо контент залежно від обраного типу шкали
    if (widget.scaleType == 'berg') {
      _scaleItems = ClinicalRepository.bergScale;
      _scaleName = 'Шкала балансу Берга (BBS)';
    } else {
      _scaleItems = ClinicalRepository.barthelIndex;
      _scaleName = 'Модифікований Індекс Бартел';
    }

    // За замовчуванням виставляємо початкові бали (0), щоб уникнути помилок пустих значень
    for (var item in _scaleItems) {
      _selectedScores[item.id] = item.scoreOptions.keys.first;
    }
  }

  /// Динамічний підрахунок загального бала
  int get _totalScore {
    return _selectedScores.values.fold(0, (sum, score) => sum + score);
  }

  /// Отримання інтерпретації в реальному часі
  String get _currentInterpretation {
    if (widget.scaleType == 'berg') {
      return ClinicalRepository.interpretBerg(_totalScore);
    } else {
      return ClinicalRepository.interpretBarthel(_totalScore);
    }
  }

  /// Метод збереження результатів тестування в провайдер
  void _saveAssessmentResult() {
    final result = AssessmentResult(
      scaleName: _scaleName,
      date: DateTime.now(),
      totalScore: _totalScore,
      interpretation: _currentInterpretation,
      itemScores: Map<int, int>.from(_selectedScores),
    );

    Provider.of<RehabProvider>(context, listen: false).saveAssessment(
      widget.patientId,
      result,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Результат $_scaleName успішно внесено до картки пацієнта!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_scaleName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Інформаційна панель поточного результату (завжди зверху)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Сумарний клінічний бал:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_totalScore балів',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Інтерпретація МОЗ: $_currentInterpretation',
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.w500, 
                    color: Colors.blueGrey.shade800,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ],
            ),
          ),

          // Покроковий список тестових завдань та критеріїв оцінки
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _scaleItems.length,
              itemBuilder: (context, index) {
                final item = _scaleItems[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Номер та опис рухової дії пацієнта
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blueGrey.shade100,
                              child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.instruction,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        
                        // Варіанти оцінювання у вигляді RadioListTile
                        Column(
                          children: item.scoreOptions.entries.map((option) {
                            final scoreValue = option.key;
                            final scoreDescription = option.value;
                            
                            return RadioListTile<int>(
                              title: Text(
                                '[$scoreValue балів] $scoreDescription',
                                style: const TextStyle(fontSize: 13, height: 1.3),
                              ),
                              value: scoreValue,
                              groupValue: _selectedScores[item.id],
                              dense: true,
                              activeColor: Colors.blue.shade700,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedScores[item.id] = newValue;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Нижня кнопка збереження тестування
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt),
                label: const Text('Фіксувати результат у медичну карту', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveAssessmentResult,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
