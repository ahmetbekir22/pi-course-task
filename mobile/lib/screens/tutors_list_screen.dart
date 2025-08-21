import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tutors_provider.dart';
import '../providers/subjects_provider.dart';
import 'tutor_detail_screen.dart';

class TutorsListScreen extends ConsumerStatefulWidget {
  const TutorsListScreen({super.key});

  @override
  ConsumerState<TutorsListScreen> createState() => _TutorsListScreenState();
}

class _TutorsListScreenState extends ConsumerState<TutorsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).loadSubjects();
      ref.read(tutorsProvider.notifier).loadTutors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorsState = ref.watch(tutorsProvider);
    final subjectsState = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitmenler'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Subject filter
                if (subjectsState.subjects.isNotEmpty)
                  DropdownButtonFormField<int?>(
                    value: tutorsState.selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Konu',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subject),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tüm Konular'),
                      ),
                      ...subjectsState.subjects.map((subject) => DropdownMenuItem<int?>(
                        value: subject.id,
                        child: Text(subject.name),
                      )),
                    ],
                    onChanged: (value) {
                      ref.read(tutorsProvider.notifier).updateFilters(subjectId: value);
                    },
                  ),
                const SizedBox(height: 16),
                
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Ara',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(tutorsProvider.notifier).updateFilters(search: '');
                      },
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(tutorsProvider.notifier).updateFilters(search: value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Ordering
                DropdownButtonFormField<String>(
                  value: tutorsState.ordering,
                  decoration: const InputDecoration(
                    labelText: 'Sıralama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sort),
                  ),
                  items: const [
                    DropdownMenuItem(value: '-rating', child: Text('Puana Göre (Yüksek)')),
                    DropdownMenuItem(value: 'rating', child: Text('Puana Göre (Düşük)')),
                    DropdownMenuItem(value: '-hourly_rate', child: Text('Ücrete Göre (Yüksek)')),
                    DropdownMenuItem(value: 'hourly_rate', child: Text('Ücrete Göre (Düşük)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(tutorsProvider.notifier).updateFilters(ordering: value);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: tutorsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tutorsState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hata: ${tutorsState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(tutorsProvider.notifier).loadTutors(),
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : tutorsState.tutors.isEmpty
                        ? const Center(
                            child: Text('Eğitmen bulunamadı'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: tutorsState.tutors.length,
                            itemBuilder: (context, index) {
                              final tutor = tutorsState.tutors[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    tutor.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (tutor.bio != null && tutor.bio!.isNotEmpty)
                                        Text(tutor.bio!),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 16),
                                          Text(' ${tutor.rating?.toStringAsFixed(1) ?? 'N/A'}'),
                                          const SizedBox(width: 16),
                                          Icon(Icons.attach_money, size: 16),
                                          Text(' ${tutor.hourlyRate}/saat'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: tutor.subjects.map((subject) => Chip(
                                          label: Text(subject.name),
                                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        )).toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TutorDetailScreen(tutorId: tutor.id),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
} 