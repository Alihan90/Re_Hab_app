import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Переводимо імпорти на абсолютні пакети для стабільності білду на CI/CD
import 'package:re_hab_app/data/database/app_database.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';
import 'package:re_hab_app/providers/auth_provider.dart';
import 'package:re_hab_app/providers/ui_state_provider.dart';
import 'package:re_hab_app/screens/auth/login_screen.dart';
import 'package:re_hab_app/screens/main_navigation_hub.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ініціалізуємо єдиний екземпляр бази даних Drift
  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiStateProvider()),
        ChangeNotifierProvider(create: (_) => RehabProvider(database)),
        ChangeNotifierProvider(create: (_) => AuthProvider(database)),
      ],
      child: const ReHabApp(),
    ),
  );
}

class ReHabApp extends StatelessWidget {
  const ReHabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiState = Provider.of<UiStateProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'ReHab Професіонал',
      debugShowCheckedModeBanner: false,
      
      // Динамічне підключення темної/світлої теми з провайдера
      themeMode: uiState.themeMode,
      locale: uiState.locale,
      
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),

      // Розумна перевірка авторизації при запуску
      home: authProvider.isAuthenticated 
          ? MainNavigationHub() // Прибрано const, щоб не було помилки компіляції
          : const LoginScreen(),
    );
  }
}
