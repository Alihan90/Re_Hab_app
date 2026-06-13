import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_hab_app/providers/auth_provider.dart';
import 'package:re_hab_app/providers/rehab_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isRegister = false;
  String _selectedRole = 'Doctor';
  final List<String> _roles = ['Doctor', 'Physical Therapist', 'Assistant'];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Функція для створення безпечного системного email із імені (для бекенду)
  String _generateSystemEmail(String name) {
    // Прибираємо пробіли, переводимо в нижній регістр і робимо локальний домен
    final cleanName = name.trim().toLowerCase().replaceAll(' ', '_');
    return '$cleanName@rehab.local';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rehabProvider = Provider.of<RehabProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegister ? 'Реєстрація спеціаліста' : 'Вхід до системи'),
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Іконка для гарного вигляду
                Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                
                // ПОЛЕ: ІМ'Я / ЛОГІН
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Ім'я або Логін",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Введіть ім'я";
                    if (v.trim().length < 3) return "Ім'я занадто коротке";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ПОЛЕ: ПАРОЛЬ
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Пароль має бути від 6 символів' : null,
                ),
                const SizedBox(height: 16),

                // ПОЛЕ: ВИБІР СПЕЦІАЛЬНОСТІ (Показуємо лише при реєстрації)
                if (_isRegister) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Спеціалізація / Роль',
                      prefixIcon: Icon(Icons.medical_services_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // КНОПКА ДІЇ
                if (authProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final inputName = _nameController.text.trim();
                          final inputPassword = _passwordController.text.trim();
                          // Генеруємо системний email на основі введеного імені
                          final systemEmail = _generateSystemEmail(inputName);

                          if (_isRegister) {
                            // Реєстрація
                            final success = await authProvider.registerDoctor(
                              email: systemEmail,
                              username: inputName,
                              password: inputPassword,
                              fullName: inputName, // Використовуємо ім'я і як повне ім'я
                            );
                            
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Реєстрація успішна! Тепер увійдіть.')),
                              );
                              setState(() => _isRegister = false);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(authProvider.errorMessage ?? 'Помилка реєстрації')),
                              );
                            }
                          } else {
                            // Вхід
                            final success = await authProvider.loginWithPassword(
                              email: systemEmail,
                              password: inputPassword,
                              rehabProvider: rehabProvider,
                            );
                            
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(authProvider.errorMessage ?? 'Помилка авторизації (перевірте з\'єднання)')),
                              );
                            }
                          }
                        }
                      },
                      child: Text(_isRegister ? 'Зареєструватися' : 'Увійти'),
                    ),
                  ),

                const SizedBox(height: 12),
                
                // ПЕРЕМИКАЧ МІЖ ВХОДОМ ТА РЕЄСТРАЦІЄЮ
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegister = !_isRegister;
                    });
                  },
                  child: Text(_isRegister ? 'Вже є акаунт? Увійти за ім\'ям' : 'Новий спеціаліст? Створити профіль'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
