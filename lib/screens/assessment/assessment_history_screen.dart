import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart'; // Пакет для запуску файлу на пристрої
import '../../services/pdf_generator_service.dart';
import '../../data/models/patient.dart'; // Твій шлях до моделі пацієнта

// Всередині AppBar -> actions:
actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12.0),
    child: IconButton(
      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 28),
      tooltip: 'Експорт карти ІРП у PDF',
      onPressed: () async {
        try {
          // Показуємо індикатор завантаження, щоб лікар розумів, що процес іде
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          // 1. Отримуємо поточний екземпляр пацієнта (переконайся, що об'єкт patient доступний у твоєму віджеті)
          // Примітка: Об'єкт `patient` має бути переданий у конструктор екрану історії або взятий із провайдера
          final PdfGeneratorService pdfService = PdfGeneratorService();
          
          // 2. Запускаємо генерацію 
          final File pdfFile = await pdfService.generateAndSavePdf(patient);

          // Закриваємо індикатор завантаження
          Navigator.pop(context);

          // 3. Відкриваємо готовий медичний PDF звіт
          await OpenFile.open(pdfFile.path);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Звіт успішно збережено: ${pdfFile.path.split('/').last}')),
          );
        } catch (e) {
          Navigator.pop(context); // Закриваємо прогрес-бар у разі збою
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Помилка генерації PDF: $e'), backgroundColor: Colors.red),
          );
        }
      },
    ),
  ),
],
