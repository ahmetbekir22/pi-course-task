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
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTutorDetail,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : tutor == null
                  ? const Center(child: Text('Eğitmen bulunamadı'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tutor Info Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tutor!.name ?? 'İsimsiz Eğitmen',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tutor!.email,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Rating and Hourly Rate
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      Text(
                                        ' ${tutor!.tutorProfile?.rating?.toStringAsFixed(1) ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 24),
                                      Icon(Icons.attach_money, size: 20),
                                      Text(
                                        ' ${tutor!.tutorProfile?.hourlyRate ?? 0}/saat',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Bio
                                  if (tutor!.tutorProfile?.bio != null && tutor!.tutorProfile!.bio!.isNotEmpty) ...[
                                    Text(
                                      'Hakkında:',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(tutor!.tutorProfile!.bio!),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // Subjects
                                  if (tutor!.tutorProfile?.subjects.isNotEmpty == true) ...[
                                    Text(
                                      'Uzmanlık Alanları:',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: tutor!.tutorProfile!.subjects.map((subject) => Chip(
                                        label: Text(subject.name),
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
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
                              icon: const Icon(Icons.school),
                              label: const Text('Ders Talep Et'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
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