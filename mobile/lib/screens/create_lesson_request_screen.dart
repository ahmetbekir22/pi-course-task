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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Talebi Oluştur'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutor Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text('Eğitmen'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Subject Selection
              DropdownButtonFormField<int>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Konu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
                items: subjectsState.subjects.map((subject) => DropdownMenuItem<int>(
                  value: subject.id,
                  child: Text(subject.name),
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
              
              const SizedBox(height: 16),
              
              // Date and Time Selection
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tarih ve Saat *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!)
                        : 'Tarih ve saat seçin',
                    style: TextStyle(
                      color: _selectedDateTime != null ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Duration Selection
              DropdownButtonFormField<int>(
                value: _durationMinutes,
                decoration: const InputDecoration(
                  labelText: 'Süre *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('30 dakika')),
                  DropdownMenuItem(value: 60, child: Text('1 saat')),
                  DropdownMenuItem(value: 90, child: Text('1.5 saat')),
                  DropdownMenuItem(value: 120, child: Text('2 saat')),
                ],
                onChanged: (value) {
                  setState(() {
                    _durationMinutes = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (Opsiyonel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Ders hakkında ek bilgiler...',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Error Display
              if (lessonRequestsState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    lessonRequestsState.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: lessonRequestsState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: lessonRequestsState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Ders Talebi Oluştur'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 