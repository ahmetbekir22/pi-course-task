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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLogin = true;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
          firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
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
    
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Dynamic dimensions based on screen size
    final padding = screenWidth * 0.04; // 4% of screen width
    final spacing = screenHeight * 0.02; // 2% of screen height
    final largeSpacing = screenHeight * 0.04; // 4% of screen height
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final fontSize = screenWidth * 0.04;
    final buttonPadding = screenHeight * 0.02;
    final errorPadding = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: largeSpacing),
              Text(
                _isLogin ? 'Pi Course\'a Hoş Geldiniz' : 'Hesap Oluştur',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: fontSize * 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: largeSpacing),
              
              if (!_isLogin) ...[
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Ad (Opsiyonel)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, size: iconSize),
                    hintText: 'Adınız',
                  ),
                  style: TextStyle(fontSize: fontSize),
                  onChanged: (value) {
                    if (authState.error != null) {
                      ref.read(authProvider.notifier).clearError();
                    }
                  },
                ),
                SizedBox(height: spacing),
                
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Soyad (Opsiyonel)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, size: iconSize),
                    hintText: 'Soyadınız',
                  ),
                  style: TextStyle(fontSize: fontSize),
                  onChanged: (value) {
                    if (authState.error != null) {
                      ref.read(authProvider.notifier).clearError();
                    }
                  },
                ),
                SizedBox(height: spacing),
              ],
              
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, size: iconSize),
                  hintText: 'ornek@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: fontSize),
                validator: _validateEmail,
                onChanged: (value) {
                  // Clear error when user starts typing
                  if (authState.error != null) {
                    ref.read(authProvider.notifier).clearError();
                  }
                },
              ),
              SizedBox(height: spacing),
              
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, size: iconSize),
                  hintText: 'En az 8 karakter',
                ),
                obscureText: true,
                style: TextStyle(fontSize: fontSize),
                validator: _validatePassword,
                onChanged: (value) {
                  // Clear error when user starts typing
                  if (authState.error != null) {
                    ref.read(authProvider.notifier).clearError();
                  }
                },
              ),
              SizedBox(height: spacing),
              
              if (!_isLogin) ...[
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, size: iconSize),
                  ),
                  items: [
                    DropdownMenuItem(value: 'student', child: Text('Öğrenci', style: TextStyle(fontSize: fontSize))),
                    DropdownMenuItem(value: 'tutor', child: Text('Eğitmen', style: TextStyle(fontSize: fontSize))),
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
                SizedBox(height: spacing),
              ],
              
              if (authState.error != null) ...[
                Container(
                  padding: EdgeInsets.all(errorPadding),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(errorPadding * 0.7),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: iconSize),
                      SizedBox(width: spacing),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: fontSize * 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing),
              ],
              
              ElevatedButton(
                onPressed: authState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                ),
                child: authState.isLoading
                    ? SizedBox(
                        height: fontSize,
                        width: fontSize,
                        child: CircularProgressIndicator(strokeWidth: fontSize * 0.1),
                      )
                    : Text(
                        _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                        style: TextStyle(fontSize: fontSize),
                      ),
              ),
              SizedBox(height: spacing),
              
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
                  style: TextStyle(fontSize: fontSize * 0.9),
                ),
              ),
              
              if (_isLogin) ...[
                SizedBox(height: spacing),
                const Divider(),
                SizedBox(height: spacing),
                Text(
                  'Demo Hesaplar:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  'Öğrenci: student1@demo.com / Passw0rd!\n'
                  'Eğitmen: tutor1@demo.com / Passw0rd!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize * 0.75, color: Colors.grey),
                ),
              ],
              SizedBox(height: largeSpacing),
            ],
          ),
        ),
      ),
    );
  }
} 