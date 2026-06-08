import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rehab_provider.dart';
import '../../data/models/scale_assessment.dart';

class ScalesScreen extends StatefulWidget {
  const ScalesScreen({Key? key}) : super(key: key);

  @override
  State<ScalesScreen> createState() => _ScalesScreenState();
}

class _ScalesScreenState extends State<ScalesScreen> {
  // Локальний статичний реєстр медичних шкал без спрощень
  final List<ScaleAssessment> _availableScales = [
    const ScaleAssessment(
      id: 'SCALE_BARTHEL',
      nameUk: 'Індекс повсякденної активності Бартел (Barthel Index)',
      nameEn: 'Barthel Index of Activities of Daily Living',
      category: '🧠 Неврологія та загальна залежність',
      descriptionUk: 'Оцінка рівня самостійності пацієнта у повсякденному житті (харчування, особиста гігієна, переміщення).',
      descriptionEn: 'Assessment of patient independence in activities of daily living.',
      questions: [
        ScaleQuestion(
          id: 'B1',
          textUk: 'Харчування пацієнта',
          textEn: 'Feeding status',
          options: [
            ScaleOption(textUk: 'Повна залежність від допомоги', textEn: 'Unable', score: 0),
            ScaleOption(textUk: 'Потребує допомоги (наприклад, різати їжу)', textEn: 'Needs help', score: 5),
            ScaleOption(textUk: 'Повністю самостійний', textEn: 'Independent', score: 10),
          ],
        ),
        ScaleQuestion(
          id: 'B2',
          textUk: 'Переміщення (з ліжка на стілець і назад)',
          textEn: 'Transfers (bed to chair and back)',
          options: [
            ScaleOption(textUk: 'Повна нерухомість, безсилля', textEn: 'Unable', score: 0),
            ScaleOption(textUk: 'Потребує значної фізичної допомоги (1-2 особи)', textEn: 'Major help', score: 5),
            ScaleOption(textUk: 'Потребує мінімальної допомоги / нагляду', textEn: 'Minor help', score: 10),
            ScaleOption(textUk: 'Повністю самостійний перехід', textEn: 'Independent', score: 15),
          ],
        ),
      ],
    ),
    const ScaleAssessment(
      id: 'SCALE_ASHWORTH',
      nameUk: 'Модифікована шкала спастичності Ашворта (MAS)',
      nameEn: 'Modified Ashworth Scale for Spasticity',
      category: '🧠 Неврологія та оцінка тонусу',
      descriptionUk: 'Оцінка опору м\'язів під час пасивного розтягування кінцівки.',
      descriptionEn: 'Measurement of muscle tone and resistance to passive movement.',
      questions: [
        ScaleQuestion(
          id: 'A1',
          textUk: 'Рівень м\'язового тонусу у тестованій групі',
          textEn: 'Muscle tone level resistance',
          options: [
            ScaleOption(textUk: '0 - Немає підвищення тонусу', textEn: 'No increase in tone', score: 0),
            ScaleOption(textUk: '1 - Легке підвищення тонусу (напруга в кінці руху)', textEn: 'Slight increase, catch and release', score: 1),
            ScaleOption(textUk: '2 - Помірне підвищення тонусу по всьому руху, але кінцівка рухається легко', textEn: 'Marked increase, but easily flexed', score: 2),
            ScaleOption(textUk: '3 - Значне підвищення тонусу, пасивний рух ускладнений', textEn: 'Considerable increase, passive movement difficult', score: 3),
            ScaleOption(textUk: '4 - Уражена частина зафіксована у згинанні або розгинанні (ригідність)', textEn: 'Affected part rigid', score: 4),
          ],
        )
      ],
    )
  ];

  void _runScaleAssessmentEngine(BuildContext context, ScaleAssessment scale, bool isUk) {
    Map<String, int> answers = {};
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            int currentScore = answers.values.fold(0, (sum, val) => sum + val);

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isUk ? scale.nameUk : scale.nameEn, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 8),
                    Text(isUk ? scale.descriptionUk : scale.descriptionEn, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const Divider(height: 24),
                    
                    ...scale.questions.map((question) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(isUk ? question.textUk : question.textEn, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                          ...question.options.map((option) {
                            return RadioListTile<int>(
                              title: Text(isUk ? option.textUk : option.textEn),
                              secondary: Chip(label: Text('+${option.score}')),
                              value: option.score,
                              groupValue: answers[question.id],
                              activeColor: Colors.teal,
                              onChanged: (val) {
                                setModalState(() {
                                  answers[question.id] = val!;
                                });
                              },
                            );
                          }).toList(),
                          const Divider(),
                        ],
                      );
                    }).toList(),

                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.teal.withOpacity(0.1),
                      width: double.infinity,
                      child: Text(
                        '${isUk ? 'Поточний підсумок' : 'Total Calculated Score'}: $currentScore ${isUk ? 'балів' : 'points'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 45)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showResultInterpretationDialog(context, scale.id, currentScore, isUk);
                      },
                      child: Text(isUk ? 'Зафіксувати результат тестування' : 'Submit Assessment'),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResultInterpretationDialog(BuildContext context, String scaleId, int score, bool isUk) {
    String interpretation = "";
    if (scaleId == 'SCALE_BARTHEL') {
      if (score <= 20) interpretation = "Повна залежність у життєдіяльності.";
      else if (score <= 60) interpretation = "Виражена залежність від сторонньої допомоги.";
      else if (score <= 90) interpretation = "Помірна залежність.";
      else interpretation = "Пацієнт повністю незалежний у побуті.";
    } else {
      interpretation = "Діагностична оцінка зафіксована успішно згідно з клінічними критеріями.";
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUk ? 'Клінічний висновок' : 'Clinical Conclusion'),
        content: Text('${isUk ? 'Сумарний бал' : 'Total Score'}: $score\n\n$interpretation'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);
    final isUk = provider.locale == 'uk';

    return Scaffold(
      appBar: AppBar(title: Text(isUk ? 'Клінічні шкали й тести' : 'Clinical Assessments'), backgroundColor: Colors.teal),
      body: ListView.builder(
        itemCount: _availableScales.length,
        itemBuilder: (context, index) {
          final scale = _availableScales[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(isUk ? scale.nameUk : scale.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${isUk ? 'Категорія' : 'Category'}: ${scale.category}'),
              trailing: const Icon(Icons.play_circle_fill, color: Colors.teal, size: 32),
              onTap: () => _runScaleAssessmentEngine(context, scale, isUk),
            ),
          );
        },
      ),
    );
  }
}
