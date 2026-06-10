import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/app_database.dart';
import 'providers/rehab_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ui_state_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_hub.dart';

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
          ? const MainNavigationHub() 
          : const LoginScreen(),
    );
  }
}
