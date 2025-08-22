import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/subjects_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gradeLevelController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  List<int> _selectedSubjectIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).loadSubjects();
    });
    
    final user = ref.read(authProvider).user;
    if (user != null) {
      if (user.role == 'student') {
        _gradeLevelController.text = user.studentProfile?.gradeLevel ?? '';
      } else if (user.role == 'tutor') {
        _bioController.text = user.tutorProfile?.bio ?? '';
        _hourlyRateController.text = (user.tutorProfile?.hourlyRate ?? 0).toString();
        _selectedSubjectIds = user.tutorProfile?.subjects.map((s) => s.id).toList() ?? [];
      }
    }
  }

  @override
  void dispose() {
    _gradeLevelController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isStudent = user.role == 'student';

    final gradeLevel = isStudent ? _gradeLevelController.text.trim() : null;
    final bio = !isStudent ? _bioController.text.trim() : null;
    final hourlyRate = !isStudent ? int.tryParse(_hourlyRateController.text.trim()) : null;
    final subjectIds = !isStudent ? _selectedSubjectIds : null;

    await ref.read(authProvider.notifier).updateProfile(
      gradeLevel: gradeLevel?.isEmpty == true ? null : gradeLevel,
      bio: bio?.isEmpty == true ? null : bio,
      hourlyRate: hourlyRate,
      subjectIds: subjectIds,
    );

    final authState = ref.read(authProvider);
    if (authState.error == null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final subjectsState = ref.watch(subjectsProvider);
    final user = authState.user!;
    final isStudent = user.role == 'student';
    
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Dynamic dimensions based on screen size
    final padding = screenWidth * 0.04; // 4% of screen width
    final spacing = screenHeight * 0.02; // 2% of screen height
    final largeSpacing = screenHeight * 0.03;
    final iconSize = screenWidth * 0.06; // 6% of screen width
    final fontSize = screenWidth * 0.04;
    final buttonPadding = screenHeight * 0.02;
    final errorPadding = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.person, size: iconSize),
                  title: Text(
                    user.name ?? user.email,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  subtitle: Text(
                    isStudent ? 'Öğrenci' : 'Eğitmen',
                    style: TextStyle(fontSize: fontSize * 0.9),
                  ),
                ),
              ),
              SizedBox(height: spacing),

              if (isStudent) ...[
                TextFormField(
                  controller: _gradeLevelController,
                  decoration: InputDecoration(
                    labelText: 'Sınıf Seviyesi',
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: fontSize),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen sınıf seviyesini girin';
                    }
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Biyografi',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _hourlyRateController,
                  decoration: InputDecoration(
                    labelText: 'Saatlik Ücret',
                    prefixText: '₺ ',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: fontSize),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen saatlik ücreti girin';
                    }
                    final val = int.tryParse(value.trim());
                    if (val == null || val < 0) {
                      return 'Geçerli bir sayı girin (>= 0)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: spacing),
                
                // Subject Selection
                if (subjectsState.subjects.isNotEmpty) ...[
                  Text(
                    'Verebileceğiniz Dersler',
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
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.symmetric(horizontal: spacing),
                        )),
                      ],
                    ),
                  ),
                ],
              ],

              SizedBox(height: largeSpacing),

              if (authState.error != null) ...[
                Container(
                  padding: EdgeInsets.all(errorPadding),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(errorPadding * 0.7),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    authState.error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: fontSize * 0.9),
                  ),
                ),
                SizedBox(height: spacing),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authState.isLoading ? null : _submit,
                  icon: Icon(Icons.save, size: iconSize),
                  label: authState.isLoading
                      ? SizedBox(
                          width: fontSize,
                          height: fontSize,
                          child: CircularProgressIndicator(strokeWidth: fontSize * 0.1),
                        )
                      : Text(
                          'Kaydet',
                          style: TextStyle(fontSize: fontSize),
                        ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}