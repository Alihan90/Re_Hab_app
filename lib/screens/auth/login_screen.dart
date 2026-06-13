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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isRegister = false;
  String _selectedRole = 'Doctor';
  final List<String> _roles = ['Doctor', 'Physical Therapist', 'Assistant'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rehabProvider = Provider.of<RehabProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Реєстрація' : 'Вхід до системи')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_isRegister)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Повне ім'я"),
                    validator: (v) => v == null || v.isEmpty ? 'Введіть ім\'я' : null,
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Некоректний Email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Пароль занадто короткий' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Посада / Роль'),
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
                if (authProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_isRegister) {
                          final success = await authProvider.registerDoctor(
                            email: _emailController.text.trim(),
                            username: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            fullName: _nameController.text.trim(),
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Реєстрація успішна!')),
                            );
                            setState(() => _isRegister = false);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.errorMessage ?? 'Помилка реєстрації')),
                            );
                          }
                        } else {
                          final success = await authProvider.loginWithPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            rehabProvider: rehabProvider,
                          );
                          if (success && mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.errorMessage ?? 'Невірний email або пароль')),
                            );
                          }
                        }
                      }
                    },
                    child: Text(_isRegister ? 'Зареєструватися' : 'Увійти'),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegister = !_isRegister;
                    });
                  },
                  child: Text(_isRegister ? 'Вже є акаунт? Увійти' : 'Немає акаунту? Реєстрація'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
