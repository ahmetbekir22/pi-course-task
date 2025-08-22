import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/subjects_provider.dart';

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
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  bool _isLogin = true;
  String _selectedRole = 'student';
  List<int> _selectedSubjectIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLogin) {
        ref.read(subjectsProvider.notifier).loadSubjects();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
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
          bio: _selectedRole == 'tutor' ? _bioController.text.trim() : null,
          hourlyRate: _selectedRole == 'tutor' ? int.tryParse(_hourlyRateController.text.trim()) : null,
          subjectIds: _selectedRole == 'tutor' ? _selectedSubjectIds : null,
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

  String? _validateHourlyRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Saatlik ücret gerekli';
    }
    
    final rate = int.tryParse(value);
    if (rate == null || rate < 0) {
      return 'Geçerli bir sayı girin (>= 0)';
    }
    
    return null;
  }

  String? _validateSubjects() {
    if (_selectedRole == 'tutor' && _selectedSubjectIds.isEmpty) {
      return 'En az bir konu seçmelisiniz';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final subjectsState = ref.watch(subjectsProvider);
    
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
                // Role Selection
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
                      _selectedSubjectIds.clear();
                    });
                    // Load subjects if tutor is selected
                    if (value == 'tutor') {
                      ref.read(subjectsProvider.notifier).loadSubjects();
                    }
                    // Clear error when user changes role
                    if (authState.error != null) {
                      ref.read(authProvider.notifier).clearError();
                    }
                  },
                ),
                SizedBox(height: spacing),
                
                // Tutor-specific fields
                if (_selectedRole == 'tutor') ...[
                  // Bio
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Biyografi (Opsiyonel)',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description, size: iconSize),
                      hintText: 'Kendinizi tanıtın...',
                    ),
                    maxLines: 3,
                    style: TextStyle(fontSize: fontSize),
                    onChanged: (value) {
                      if (authState.error != null) {
                        ref.read(authProvider.notifier).clearError();
                      }
                    },
                  ),
                  SizedBox(height: spacing),
                  
                  // Hourly Rate
                  TextFormField(
                    controller: _hourlyRateController,
                    decoration: InputDecoration(
                      labelText: 'Saatlik Ücret *',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money, size: iconSize),
                      hintText: '₺ 0',
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: fontSize),
                    validator: _validateHourlyRate,
                    onChanged: (value) {
                      if (authState.error != null) {
                        ref.read(authProvider.notifier).clearError();
                      }
                    },
                  ),
                  SizedBox(height: spacing),
                  
                  // Subject Selection
                  if (subjectsState.subjects.isNotEmpty) ...[
                    Text(
                      'Verebileceğiniz Dersler *',
                      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: spacing * 0.5),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          ...subjectsState.subjects.map((subject) => CheckboxListTile(
                            title: Text(subject.name, style: TextStyle(fontSize: fontSize * 0.9)),
                            value: _selectedSubjectIds.contains(subject.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedSubjectIds.add(subject.id);
                                } else {
                                  _selectedSubjectIds.remove(subject.id);
                                }
                              });
                              if (authState.error != null) {
                                ref.read(authProvider.notifier).clearError();
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.symmetric(horizontal: spacing),
                          )),
                        ],
                      ),
                    ),
                    if (_validateSubjects() != null)
                      Padding(
                        padding: EdgeInsets.only(top: spacing * 0.5),
                        child: Text(
                          _validateSubjects()!,
                          style: TextStyle(color: Colors.red, fontSize: fontSize * 0.8),
                        ),
                      ),
                    SizedBox(height: spacing),
                  ],
                ],
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
                    _selectedSubjectIds.clear();
                    ref.read(authProvider.notifier).clearError();
                  });
                  if (!_isLogin) {
                    ref.read(subjectsProvider.notifier).loadSubjects();
                  }
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