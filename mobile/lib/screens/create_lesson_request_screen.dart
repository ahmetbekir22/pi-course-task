import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_request.dart';
import '../providers/subjects_provider.dart';
import '../providers/lesson_requests_provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class CreateLessonRequestScreen extends ConsumerStatefulWidget {
  final int tutorId;
  final String tutorName;

  const CreateLessonRequestScreen({
    super.key,
    required this.tutorId,
    required this.tutorName,
  });

  @override
  ConsumerState<CreateLessonRequestScreen> createState() => _CreateLessonRequestScreenState();
}

class _CreateLessonRequestScreenState extends ConsumerState<CreateLessonRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  int? _selectedSubjectId;
  DateTime? _selectedDateTime;
  int _durationMinutes = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).loadSubjects();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 1));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dial,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final request = CreateLessonRequest(
        tutorId: widget.tutorId,
        subjectId: _selectedSubjectId!,
        startTime: _selectedDateTime!,
        durationMinutes: _durationMinutes,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      final user = ref.read(authProvider).user;
      if (user != null) {
        await ref.read(lessonRequestsProvider.notifier).createLessonRequest(request, user.role);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ders talebi başarıyla oluşturuldu')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);
    final lessonRequestsState = ref.watch(lessonRequestsProvider);
    
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
    final buttonPadding = screenHeight * 0.02;
    final errorPadding = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Talebi Oluştur'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutor Info
              Card(
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: iconSize),
                      SizedBox(width: spacing * 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutorName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            ),
                            Text(
                              'Eğitmen',
                              style: TextStyle(fontSize: fontSize * 0.9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: largeSpacing),
              
              // Subject Selection
              DropdownButtonFormField<int>(
                value: _selectedSubjectId,
                decoration: InputDecoration(
                  labelText: 'Konu *',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject, size: iconSize * 0.6),
                ),
                items: subjectsState.subjects.map((subject) => DropdownMenuItem<int>(
                  value: subject.id,
                  child: Text(subject.name, style: TextStyle(fontSize: fontSize)),
                )).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Lütfen bir konu seçin';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedSubjectId = value;
                  });
                },
              ),
              
              SizedBox(height: spacing),
              
              // Date and Time Selection
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tarih ve Saat *',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today, size: iconSize * 0.6),
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!)
                        : 'Tarih ve saat seçin',
                    style: TextStyle(
                      color: _selectedDateTime != null ? null : Colors.grey[600],
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: spacing),
              
              // Duration Selection
              DropdownButtonFormField<int>(
                value: _durationMinutes,
                decoration: InputDecoration(
                  labelText: 'Süre *',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer, size: iconSize * 0.6),
                ),
                items: [
                  DropdownMenuItem(value: 30, child: Text('30 dakika', style: TextStyle(fontSize: fontSize))),
                  DropdownMenuItem(value: 60, child: Text('1 saat', style: TextStyle(fontSize: fontSize))),
                  DropdownMenuItem(value: 90, child: Text('1.5 saat', style: TextStyle(fontSize: fontSize))),
                  DropdownMenuItem(value: 120, child: Text('2 saat', style: TextStyle(fontSize: fontSize))),
                ],
                onChanged: (value) {
                  setState(() {
                    _durationMinutes = value!;
                  });
                },
              ),
              
              SizedBox(height: spacing),
              
              // Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Not (Opsiyonel)',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note, size: iconSize * 0.6),
                  hintText: 'Ders hakkında ek bilgiler...',
                ),
                maxLines: 3,
                style: TextStyle(fontSize: fontSize),
              ),
              
              SizedBox(height: largeSpacing),
              
              // Error Display
              if (lessonRequestsState.error != null) ...[
                Container(
                  padding: EdgeInsets.all(errorPadding),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(errorPadding * 0.7),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    lessonRequestsState.error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: fontSize * 0.9),
                  ),
                ),
                SizedBox(height: spacing),
              ],
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: lessonRequestsState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: lessonRequestsState.isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Ders Talebi Oluştur',
                          style: TextStyle(fontSize: fontSize),
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