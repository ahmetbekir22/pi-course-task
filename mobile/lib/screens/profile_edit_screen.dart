import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      if (user.role == 'student') {
        _gradeLevelController.text = user.studentProfile?.gradeLevel ?? '';
      } else if (user.role == 'tutor') {
        _bioController.text = user.tutorProfile?.bio ?? '';
        _hourlyRateController.text = (user.tutorProfile?.hourlyRate ?? 0).toString();
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

    await ref.read(authProvider.notifier).updateProfile(
      gradeLevel: gradeLevel?.isEmpty == true ? null : gradeLevel,
      bio: bio?.isEmpty == true ? null : bio,
      hourlyRate: hourlyRate,
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
    final user = authState.user!;
    final isStudent = user.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.name ?? user.email),
                  subtitle: Text(isStudent ? 'Öğrenci' : 'Eğitmen'),
                ),
              ),
              const SizedBox(height: 16),

              if (isStudent) ...[
                TextFormField(
                  controller: _gradeLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf Seviyesi',
                    border: OutlineInputBorder(),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Biyografi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hourlyRateController,
                  decoration: const InputDecoration(
                    labelText: 'Saatlik Ücret',
                    prefixText: '₺ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
              ],

              const SizedBox(height: 24),

              if (authState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    authState.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authState.isLoading ? null : _submit,
                  icon: const Icon(Icons.save),
                  label: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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