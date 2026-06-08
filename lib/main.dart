import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/app_database.dart';
import 'data/repositories/patient_repository.dart';
import 'providers/rehab_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  // Гарантуємо ініціалізацію системних каналів Flutter перед запуском БД
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізуємо єдиний екземпляр локальної бази даних Drift
  final AppDatabase database = AppDatabase();
  
  // Передаємо базу даних в абстрагований репозиторій
  final PatientRepository patientRepository = LocalPatientRepository(database);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RehabProvider>(
          create: (_) => RehabProvider(patientRepository),
        ),
      ],
      child: const RehabilitationApp(),
    ),
  );
}

class RehabilitationApp extends StatelessWidget {
  const RehabilitationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RehabProvider>(context);

    return MaterialApp(
      title: 'Re_Hab_app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: provider.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
