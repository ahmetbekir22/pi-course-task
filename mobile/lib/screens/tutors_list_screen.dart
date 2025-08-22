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
    
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Dynamic dimensions based on screen size
    final padding = screenWidth * 0.04; // 4% of screen width
    final spacing = screenHeight * 0.02; // 2% of screen height
    final iconSize = screenWidth * 0.04; // 4% of screen width
    final fontSize = screenWidth * 0.035;
    final largeIconSize = screenWidth * 0.16; // 16% of screen width
    final cardMargin = screenHeight * 0.02;
    final listPadding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitmenler'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // Subject filter
                if (subjectsState.subjects.isNotEmpty)
                  DropdownButtonFormField<int?>(
                    value: tutorsState.selectedSubjectId,
                    decoration: InputDecoration(
                      labelText: 'Konu',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subject, size: iconSize),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tüm Konular', style: TextStyle(fontSize: fontSize)),
                      ),
                      ...subjectsState.subjects.map((subject) => DropdownMenuItem<int?>(
                        value: subject.id,
                        child: Text(subject.name, style: TextStyle(fontSize: fontSize)),
                      )),
                    ],
                    onChanged: (value) {
                      ref.read(tutorsProvider.notifier).updateFilters(subjectId: value);
                    },
                  ),
                SizedBox(height: spacing),
                
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Ara',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search, size: iconSize),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, size: iconSize),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(tutorsProvider.notifier).updateFilters(search: '');
                      },
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(tutorsProvider.notifier).updateFilters(search: value);
                  },
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: spacing),
                
                // Ordering
                DropdownButtonFormField<String>(
                  value: tutorsState.ordering,
                  decoration: InputDecoration(
                    labelText: 'Sıralama',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sort, size: iconSize),
                  ),
                  items: [
                    DropdownMenuItem(value: '-rating', child: Text('Puana Göre (Yüksek)', style: TextStyle(fontSize: fontSize))),
                    DropdownMenuItem(value: 'rating', child: Text('Puana Göre (Düşük)', style: TextStyle(fontSize: fontSize))),
                    DropdownMenuItem(value: '-hourly_rate', child: Text('Ücrete Göre (Yüksek)', style: TextStyle(fontSize: fontSize))),
                    DropdownMenuItem(value: 'hourly_rate', child: Text('Ücrete Göre (Düşük)', style: TextStyle(fontSize: fontSize))),
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
                        child: Padding(
                          padding: EdgeInsets.all(padding * 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: largeIconSize,
                                color: Colors.orange.shade600,
                              ),
                              SizedBox(height: spacing),
                              Text(
                                tutorsState.error!,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: fontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: spacing * 1.5),
                              ElevatedButton.icon(
                                onPressed: () => ref.read(tutorsProvider.notifier).loadTutors(),
                                icon: Icon(Icons.refresh, size: iconSize),
                                label: Text('Tekrar Dene', style: TextStyle(fontSize: fontSize * 0.9)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : tutorsState.tutors.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(padding * 1.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: largeIconSize,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: spacing),
                                  Text(
                                    'Eğitmen bulunamadı',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: fontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  Text(
                                    'Farklı filtreler deneyebilir veya arama terimini değiştirebilirsiniz',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: fontSize * 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(listPadding),
                            itemCount: tutorsState.tutors.length,
                            itemBuilder: (context, index) {
                              final tutor = tutorsState.tutors[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: cardMargin),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(padding),
                                  title: Text(
                                    tutor.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (tutor.bio != null && tutor.bio!.isNotEmpty)
                                        Text(
                                          tutor.bio!,
                                          style: TextStyle(fontSize: fontSize * 0.9),
                                        ),
                                      SizedBox(height: spacing),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: iconSize),
                                          Text(
                                            ' ${tutor.rating?.toStringAsFixed(1) ?? 'N/A'}',
                                            style: TextStyle(fontSize: fontSize * 0.9),
                                          ),
                                          SizedBox(width: spacing * 2),
                                          Icon(Icons.attach_money, size: iconSize),
                                          Text(
                                            ' ${tutor.hourlyRate}/saat',
                                            style: TextStyle(fontSize: fontSize * 0.9),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: spacing),
                                      Wrap(
                                        spacing: spacing,
                                        children: tutor.subjects.map((subject) => Chip(
                                          label: Text(
                                            subject.name,
                                            style: TextStyle(fontSize: fontSize * 0.8),
                                          ),
                                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        )).toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, size: iconSize * 0.6),
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