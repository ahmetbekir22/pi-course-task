import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      
      if (_isLogin) {
        await authNotifier.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authNotifier.register(
          _emailController.text.trim(),
          _passwordController.text,
          _selectedRole,
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta gerekli';
    }
    
    // Email format validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalı';
    }
    
    // Password strength validation
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermeli';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermeli';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermeli';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Pi Course\'a Hoş Geldiniz' : 'Hesap Oluştur',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'ornek@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                onChanged: (value) {
                  // Clear error when user starts typing
                  if (authState.error != null) {
                    ref.read(authProvider.notifier).clearError();
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'En az 8 karakter',
                ),
                obscureText: true,
                validator: _validatePassword,
                onChanged: (value) {
                  // Clear error when user starts typing
                  if (authState.error != null) {
                    ref.read(authProvider.notifier).clearError();
                  }
                },
              ),
              const SizedBox(height: 16),
              
              if (!_isLogin) ...[
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Öğrenci')),
                    DropdownMenuItem(value: 'tutor', child: Text('Eğitmen')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                    // Clear error when user changes role
                    if (authState.error != null) {
                      ref.read(authProvider.notifier).clearError();
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              if (authState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              ElevatedButton(
                onPressed: authState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    ref.read(authProvider.notifier).clearError();
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Hesabınız yok mu? Kayıt olun'
                      : 'Zaten hesabınız var mı? Giriş yapın',
                ),
              ),
              
              if (_isLogin) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Demo Hesaplar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Öğrenci: student1@demo.com / Passw0rd!\n'
                  'Eğitmen: tutor1@demo.com / Passw0rd!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 