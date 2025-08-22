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
    
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Dynamic dimensions based on screen size
    final padding = screenWidth * 0.04; // 4% of screen width
    final cardPadding = screenWidth * 0.04;
    final spacing = screenHeight * 0.02; // 2% of screen height
    final largeSpacing = screenHeight * 0.03;
    final iconSize = screenWidth * 0.08; // 8% of screen width
    final fontSize = screenWidth * 0.04;

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
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş geldiniz, ${user.name ?? user.email}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: fontSize * 1.5,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      'Rol: ${user.role == 'student' ? 'Öğrenci' : 'Eğitmen'}',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    if (user.role == 'student' && user.studentProfile?.gradeLevel != null)
                      Text(
                        'Sınıf: ${user.studentProfile!.gradeLevel}',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    if (user.role == 'tutor' && user.tutorProfile != null) ...[
                      Text(
                        'Saatlik Ücret: \$${user.tutorProfile!.hourlyRate}',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      Text(
                        'Puan: ${user.tutorProfile!.rating?.toStringAsFixed(1) ?? 'N/A'}/5',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: largeSpacing),
            
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
              SizedBox(height: spacing),
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
            
            SizedBox(height: spacing),
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    final iconSize = screenWidth * 0.08;
    final fontSize = screenWidth * 0.04;
    
    return Card(
      child: ListTile(
        leading: Icon(icon, size: iconSize),
        title: Text(title, style: TextStyle(fontSize: fontSize)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: fontSize * 0.9)),
        trailing: Icon(Icons.arrow_forward_ios, size: iconSize * 0.6),
        onTap: onTap,
      ),
    );
  }
} 