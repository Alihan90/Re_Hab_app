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
  
  bool _isCreateMode = false;
  String _selectedRole = 'Лікар';
  dynamic _selectedUser;
  
  final List<String> _roles = ['Лікар', 'Фізичний терапевт', 'Асистент'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rehabProvider = Provider.of<RehabProvider>(context, listen: false);

    // Автоматично вмикаємо режим створення профілю, якщо в базі ще нікого немає
    if (authProvider.savedUsers.isEmpty) {
      _isCreateMode = true;
    } else if (!_isCreateMode && _selectedUser == null) {
      // За замовчуванням вибираємо першого лікаря зі списку
      _selectedUser = authProvider.savedUsers.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreateMode ? 'Створення профілю' : 'Вхід у систему'),
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
                Icon(
                  Icons.medical_services,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),

                if (authProvider.errorMessage != null) ...[
                  Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: Center,
                  ),
                  const SizedBox(height: 16),
                ],

                // РЕЖИМ 1: ВИБІР ІСНУЮЧОГО СПЕЦІАЛІСТА
                if (!_isCreateMode) ...[
                  DropdownButtonFormField<dynamic>(
                    value: _selectedUser,
                    decoration: const InputDecoration(
                      labelText: 'Оберіть свій профіль',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: authProvider.savedUsers.map<DropdownMenuItem<dynamic>>((dynamic user) {
                      return DropdownMenuItem<dynamic>(
                        value: user,
                        child: Text(user.fullName ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // РЕЖИМ 2: СТВОРЕННЯ НОВОГО СПЕЦІАЛІСТА
                if (_isCreateMode) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Прізвище та Ім'я",
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? "Введіть ім'я" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Посада / Роль',
                      prefixIcon: Icon(Icons.assignment_ind_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((String val) {
                      return DropdownMenuItem<String>(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedRole = value);
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
                        if (_isCreateMode) {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.createProfileAndLogin(
                              name: _nameController.text.trim(),
                              role: _selectedRole,
                              rehabProvider: rehabProvider,
                            );
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }
                        } else {
                          if (_selectedUser != null) {
                            final success = await authProvider.loginWithSelectedUser(_selectedUser, rehabProvider);
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }
                        }
                      },
                      child: Text(_isCreateMode ? 'Створити та увійти' : 'Увійти в додаток'),
                    ),
                  ),

                const SizedBox(height: 16),
                
                // ПЕРЕМИКАЧ МІЖ РЕЖИМАМИ (Показуємо тільки якщо в базі вже хтось є)
                if (authProvider.savedUsers.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCreateMode = !_isCreateMode;
                      });
                    },
                    child: Text(_isCreateMode ? 'Повернутися до списку профілів' : 'Додати нового колегу/спеціаліста'),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
