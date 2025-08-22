import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';
import 'create_lesson_request_screen.dart';

class TutorDetailScreen extends ConsumerStatefulWidget {
  final int tutorId;

  const TutorDetailScreen({super.key, required this.tutorId});

  @override
  ConsumerState<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends ConsumerState<TutorDetailScreen> {
  User? tutor;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTutorDetail();
  }

  Future<void> _loadTutorDetail() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      print('Loading tutor detail for ID: ${widget.tutorId}');
      final tutorData = await apiClient.getTutorDetail(widget.tutorId);
      print('Tutor data received: ${tutorData.toJson()}');
      setState(() {
        tutor = tutorData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tutor detail: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Dynamic dimensions based on screen size
    final padding = screenWidth * 0.04; // 4% of screen width
    final cardPadding = screenWidth * 0.04;
    final spacing = screenHeight * 0.02; // 2% of screen height
    final smallSpacing = screenHeight * 0.01;
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final fontSize = screenWidth * 0.04;
    final buttonPadding = screenHeight * 0.02;
    final chipSpacing = screenWidth * 0.02;
    final chipRunSpacing = screenHeight * 0.01;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitmen Detayı'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hata: $error',
                        style: TextStyle(color: Colors.red, fontSize: fontSize),
                      ),
                      SizedBox(height: spacing),
                      ElevatedButton(
                        onPressed: _loadTutorDetail,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : tutor == null
                  ? Center(child: Text('Eğitmen bulunamadı', style: TextStyle(fontSize: fontSize)))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tutor Info Card
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(cardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tutor!.name ?? 'İsimsiz Eğitmen',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontSize: fontSize * 1.5,
                                    ),
                                  ),
                                  SizedBox(height: spacing),
                                  
                                  // Rating and Hourly Rate
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: iconSize),
                                      Text(
                                        ' ${tutor!.tutorProfile?.rating?.toStringAsFixed(1) ?? 'N/A'}',
                                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: spacing * 1.5),
                                      Icon(Icons.attach_money, size: iconSize),
                                      Text(
                                        ' ${tutor!.tutorProfile?.hourlyRate ?? 0}/saat',
                                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: spacing),
                                  
                                  // Bio
                                  if (tutor!.tutorProfile?.bio != null && tutor!.tutorProfile!.bio!.isNotEmpty) ...[
                                    Text(
                                      'Hakkında:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                                    ),
                                    SizedBox(height: smallSpacing),
                                    Text(
                                      tutor!.tutorProfile!.bio!,
                                      style: TextStyle(fontSize: fontSize * 0.9),
                                    ),
                                    SizedBox(height: spacing),
                                  ],
                                  
                                  // Subjects
                                  if (tutor!.tutorProfile?.subjects.isNotEmpty == true) ...[
                                    Text(
                                      'Uzmanlık Alanları:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                                    ),
                                    SizedBox(height: smallSpacing),
                                    Wrap(
                                      spacing: chipSpacing,
                                      runSpacing: chipRunSpacing,
                                      children: tutor!.tutorProfile!.subjects.map((subject) => Chip(
                                        label: Text(
                                          subject.name,
                                          style: TextStyle(fontSize: fontSize * 0.8),
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: spacing * 1.5),
                          
                          // Request Lesson Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateLessonRequestScreen(
                                      tutorId: widget.tutorId,
                                      tutorName: tutor!.name ?? 'İsimsiz Eğitmen',
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.school, size: iconSize),
                              label: Text(
                                'Ders Talep Et',
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
    );
  }
} 