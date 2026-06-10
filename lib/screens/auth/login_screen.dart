import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rehab_provider.dart';
import '../../providers/ui_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isRegisterMode = false;
  String? _selectedSavedUsername;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _triggerBiometrics(AuthProvider auth, RehabProvider rehab) {
    if (_selectedSavedUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Спочатку оберіть ваш логін зі списку збережених')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.fingerprint, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Сканування FaceID / TouchID\nдля лікаря: $_selectedSavedUsername', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await auth.loginWithBiometrics(_selectedSavedUsername!, rehab);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Біометричний збіг не знайдено')));
                }
              },
              child: const Text('Імітувати успішний дотик'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = Provider.of<UiStateProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final rehabProvider = Provider.of<RehabProvider>(context, listen: false);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.gavel_rounded, size: 64, color: Colors.blue), // Клінічний логотип
                const SizedBox(height: 16),
                Text(
                  uiState.translate('login_title'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Список збережених логінів (якщо вони є)
                if (!_isRegisterMode && authProvider.savedUsers.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedSavedUsername,
                    decoration: InputDecoration(
                      labelText: uiState.translate('select_user'),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      prefixIcon: const Icon(Icons.account_box),
                    ),
                    items: authProvider.savedUsers.map((user) {
                      return DropdownMenuItem(value: user.username, child: Text('${user.fullName} (${user.username})'));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSavedUsername = val;
                        _usernameController.text = val ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _usernameController,
                  enabled: _isRegisterMode || authProvider.savedUsers.isEmpty,
                  decoration: InputDecoration(
                    labelText: uiState.translate('username'),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty ? uiState.translate('required_field') : null,
                ),
                const SizedBox(height: 16),

                if (_isRegisterMode) ...[
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: uiState.translate('full_name'),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    validator: (v) => v == null || v.isEmpty ? uiState.translate('required_field') : null,
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: uiState.translate('password'),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (v) => v == null || v.isEmpty ? uiState.translate('required_field') : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_isRegisterMode) {
                        final success = await authProvider.registerDoctor(
                          _usernameController.text,
                          _passwordController.text,
                          _fullNameController.text,
                        );
                        if (success) {
                          setState(() => _isRegisterMode = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Спеціаліста успішно зареєстровано!')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Цей логін вже зайнятий колегою')));
                        }
                      } else {
                        final success = await authProvider.loginWithPassword(
                          _usernameController.text,
                          _passwordController.text,
                          rehabProvider,
                        );
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Невірний пароль спеціаліста')));
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_isRegisterMode ? uiState.translate('register') : uiState.translate('enter')),
                ),

                if (!_isRegisterMode && authProvider.isBiometricsEnabled && authProvider.savedUsers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    onPressed: () => _triggerBiometrics(authProvider, rehabProvider),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    label: Text(uiState.translate('bio_auth')),
                  ),
                ],

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                  child: Text(_isRegisterMode ? 'Вже є акаунт? Авторизуватись' : 'Створити картку нового лікаря в базі даних'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
