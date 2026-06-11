import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../data/models/patient.dart';

class PdfGeneratorService {
  
  /// Генерує бінарний PDF-документ на основі текстової матриці звіту
  Future<File> generateAndSavePdf(Patient patient) async {
    final pdf = pw.Document();
    final reportText = generateFullClinicalReport(patient);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Text(
              reportText,
              style: pw.TextStyle(
                font: pw.Font.courier(), // Гарантує збереження структури таблиць та символів ===
                fontSize: 9,
                lineSpacing: 1.2,
              ),
            ),
          ];
        },
      ),
    );

    // Зберігаємо у директорію документів додатку
    final output = await getApplicationDocumentsDirectory();
    final fileName = "IRP_${patient.nameEn.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Генерує структуровану текстову матрицю звіту за стандартами медичних протоколів МОЗ України.
  String generateFullClinicalReport(Patient patient) {
    final buffer = StringBuffer();

    buffer.writeln("=================================================================================");
    buffer.writeln("                      МІНІСТЕРСТВО ОХОРОНИ ЗДОРОВ'Я УКРАЇНИ                      ");
    buffer.writeln("               ІНДИВІДУАЛЬНА ПРОГРАМА РЕАБІЛІТАЦІЇ ПАЦІЄНТА (ІРП)                ");
    buffer.writeln("=================================================================================");
    buffer.writeln("ДАТА ФОРМУВАННЯ ДОКУМЕНТА: ${DateTime.now().toLocal().toString().split(' ')[0]}");
    buffer.writeln("\n1. ПАСПОРТНА ЧАСТИНА КАРТКИ ПАЦІЄНТА:");
    buffer.writeln("---------------------------------------------------------------------------------");
    buffer.writeln("ПІБ Пацієнта (укр): ${patient.nameUk}");
    buffer.writeln("Patient Full Name (eng): ${patient.nameEn}");
    buffer.writeln("Вік: ${patient.age}");
    buffer.writeln("Дата народження: ${patient.birthDate}");
    buffer.writeln("Дата взяття на реабілітаційний облік: ${patient.admissionDate}");
    
    buffer.writeln("\n2. КЛІНІКО-ФУНКЦІОНАЛЬНИЙ ДІАГНОСТИЧНИЙ ПРОФІЛЬ:");
    buffer.writeln("---------------------------------------------------------------------------------");
    buffer.writeln("Основне захворювання (UA): ${patient.generalDiagnosisUk}");
    buffer.writeln("Primary Diagnosis (EN): ${patient.generalDiagnosisEn}");
    buffer.writeln("Супутні коди за класифікатором МКХ-10: ${patient.diagnosisMkh10Codes.join(', ')}");
    buffer.writeln("Визначені домени/коди обмеження життєдіяльності за МКФ: ${patient.irp.mfkCodes}");

    buffer.writeln("\n3. ІНТЕРАКТИВНИЙ КОНСТРУКТОР СМАРТ-ЦІЛЕЙ:");
    buffer.writeln("---------------------------------------------------------------------------------");
    buffer.writeln(patient.irp.goalsSmart.isNotEmpty ? patient.irp.goalsSmart : "Короткострокові та довгострокові цілі реабілітації на даний момент не сформовані.");

    buffer.writeln("\n4. ЖУРНАЛ МОНІТОРИНГУ ВІЗИTIВ ТА СОМАТИЧНОГО СТАНУ (ЧСС, А/Т, SpO2):");
    buffer.writeln("---------------------------------------------------------------------------------");
    if (patient.visits.isEmpty) {
      buffer.writeln(" Записи про проведені лікувальні візити відсутні в локальній базі даних.");
    } else {
      for (var visit in patient.visits) {
        buffer.writeln("• Дата: ${visit.date.toLocal().toString().split(' ')[0]}");
        buffer.writeln("  [Життєві показники]: Пульс (ЧСС): ${visit.vitals.heartRate} уд/хв | Тиск (А/Т): ${visit.vitals.bloodPressure} мм рт.ст. | Кисень (SpO2): ${visit.vitals.oxygenSaturation}%");
        buffer.writeln("  [Терапевтична нотатка]: ${visit.therapeuticNote}");
        buffer.writeln("  ---");
      }
    }

    buffer.writeln("\n5. ОБ'ЄКТИВНИЙ СТАТУС - ДИНАМІКА МЕДИЧНИХ ШКАЛ ТА МІЖНАРОДНИХ ТЕСТІВ:");
    buffer.writeln("---------------------------------------------------------------------------------");
    if (patient.scaleHistory.isEmpty) {
      buffer.writeln(" Первинні та повторні тестування за funkціональними шкалами не проводились.");
    } else {
      for (var point in patient.scaleHistory) {
        buffer.writeln("• [${point.date.toString().split(' ')[0]}] Шкала: ${point.scaleNameUk}");
        buffer.writeln("  Отриманий результат: ${point.totalScore} балів");
        buffer.writeln("  Клінічна інтерпретація: ${point.interpretationUk}");
        buffer.writeln("  ---");
      }
    }

    buffer.writeln("\n6. КЛІНІЧНА ГОНІОМЕТРІЯ (ПРОТОКОЛ АМПЛІТУДИ РУХІВ СУГЛОБІВ):");
    buffer.writeln("---------------------------------------------------------------------------------");
    if (patient.goniometryHistory.isEmpty) {
      buffer.writeln(" Цифрові заміри рухливості суглобів за допомогою вбудованого гоніометра не зафіксовані.");
    } else {
      for (var gonio in patient.goniometryHistory) {
        buffer.writeln("• Дата заміру: ${gonio.date.toString().split(' ')[0]}");
        buffer.writeln("  Суглоб: ${gonio.jointNameUk} | Рух: ${gonio.movementTypeUk}");
        buffer.writeln("  Фактична амплітуда: ${gonio.measuredValueDegrees}° (Фізіологічна норма: ${gonio.normalValueDegrees}°)");
        buffer.writeln("  Експертний висновок: ${gonio.conclusionUk}");
        buffer.writeln("  ---");
      }
    }

    buffer.writeln("\n7. КАРТА ПРИЗНАЧЕННЯ ФІЗИЧНИХ ТА ДИХАЛЬНИХ ВПРАВ НА КУРС:");
    buffer.writeln("---------------------------------------------------------------------------------");
    buffer.writeln("Поточний цикл: ${patient.irp.rehabilitationCycle}");
    buffer.writeln("Тривалість курсу лікування: ${patient.irp.plannedDays} днів (з можливістю корекції)");
    buffer.writeln("План втручання: ${patient.irp.interventionPlan}");
    
    if (patient.irp.daysSchedule.isEmpty) {
      buffer.writeln(" Активний розклад занять на дні реабілітації порожній.");
    } else {
      patient.irp.daysSchedule.forEach((dayNumber, exerciseList) {
        buffer.writeln("\n [ДЕНЬ $dayNumber]");
        for (var customEx in exerciseList) {
          buffer.writeln("   - Код: ${customEx.id} | Вправа: ${customEx.title}");
          buffer.writeln("     Призначене дозування: ${customEx.dosage} ${customEx.isCustomized ? '(Увага: модифіковано лікарем)' : ''}");
        }
      });
    }

    buffer.writeln("\n=================================================================================");
    buffer.writeln("Відповідальний за реабілітацію спеціаліст: ____________________ / ${patient.irp.specialistName.isNotEmpty ? patient.irp.specialistName : 'Ковальчук О.В.'} /");
    buffer.writeln("М.П. Лікувального закладу");
    buffer.writeln("=================================================================================");

    return buffer.toString();
  }
}
