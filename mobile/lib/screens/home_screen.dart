import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'tutors_list_screen.dart';
import 'lesson_requests_screen.dart';
import 'profile_edit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user!; // User is guaranteed to be not null here

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pi Course'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş geldiniz, ${user.name ?? user.email}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Rol: ${user.role == 'student' ? 'Öğrenci' : 'Eğitmen'}'),
                    if (user.role == 'student' && user.studentProfile?.gradeLevel != null)
                      Text('Sınıf: ${user.studentProfile!.gradeLevel}'),
                    if (user.role == 'tutor' && user.tutorProfile != null) ...[
                      Text('Saatlik Ücret: \$${user.tutorProfile!.hourlyRate}'),
                      Text('Puan: ${user.tutorProfile!.rating?.toStringAsFixed(1) ?? 'N/A'}/5'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (user.role == 'student') ...[
              _buildNavigationCard(
                context,
                'Eğitmenleri Keşfet',
                'Konulara göre eğitmen arayın',
                Icons.search,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TutorsListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationCard(
                context,
                'Ders Taleplerim',
                'Gönderdiğiniz talepleri görün',
                Icons.list,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LessonRequestsScreen(),
                    ),
                  );
                },
              ),
            ] else ...[
              _buildNavigationCard(
                context,
                'Gelen Talepler',
                'Öğrencilerden gelen talepleri yönetin',
                Icons.inbox,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LessonRequestsScreen(),
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 16),
            _buildNavigationCard(
              context,
              'Profil Düzenle',
              'Profil bilgilerinizi güncelleyin',
              Icons.edit,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
} 