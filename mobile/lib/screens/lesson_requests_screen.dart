import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_request.dart';
import '../providers/lesson_requests_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class LessonRequestsScreen extends ConsumerStatefulWidget {
  const LessonRequestsScreen({super.key});

  @override
  ConsumerState<LessonRequestsScreen> createState() => _LessonRequestsScreenState();
}

class _LessonRequestsScreenState extends ConsumerState<LessonRequestsScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(lessonRequestsProvider.notifier).loadLessonRequests(role: user.role);
      }
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durum Filtresi:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Tümü'),
                selected: _statusFilter == null,
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = null;
                  });
                  final user = ref.read(authProvider).user;
                  if (user != null) {
                    ref.read(lessonRequestsProvider.notifier).loadLessonRequests(role: user.role);
                  }
                },
              ),
              FilterChip(
                label: const Text('Beklemede'),
                selected: _statusFilter == 'pending',
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = selected ? 'pending' : null;
                  });
                  final user = ref.read(authProvider).user;
                  if (user != null) {
                    ref.read(lessonRequestsProvider.notifier).loadLessonRequests(
                      status: selected ? 'pending' : null,
                      role: user.role,
                    );
                  }
                },
              ),
              FilterChip(
                label: const Text('Onaylandı'),
                selected: _statusFilter == 'approved',
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = selected ? 'approved' : null;
                  });
                  final user = ref.read(authProvider).user;
                  if (user != null) {
                    ref.read(lessonRequestsProvider.notifier).loadLessonRequests(
                      status: selected ? 'approved' : null,
                      role: user.role,
                    );
                  }
                },
              ),
              FilterChip(
                label: const Text('Reddedildi'),
                selected: _statusFilter == 'rejected',
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = selected ? 'rejected' : null;
                  });
                  final user = ref.read(authProvider).user;
                  if (user != null) {
                    ref.read(lessonRequestsProvider.notifier).loadLessonRequests(
                      status: selected ? 'rejected' : null,
                      role: user.role,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonRequestCard(LessonRequest request, bool isTutor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ders Talebi #${request.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(request.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Subject and DateTime
            Row(
              children: [
                Icon(Icons.subject, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('Konu ID: ${request.subject}'),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(request.startTime)),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Duration
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('${request.durationMinutes} dakika'),
              ],
            ),
            
            if (request.note != null && request.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not: ${request.note}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons for tutors
            if (isTutor && request.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = ref.read(authProvider).user;
                        if (user != null) {
                          await ref.read(lessonRequestsProvider.notifier).updateLessonRequest(
                            request.id,
                            UpdateLessonRequest(status: 'approved'),
                            user.role,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Onayla'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = ref.read(authProvider).user;
                        if (user != null) {
                          await ref.read(lessonRequestsProvider.notifier).updateLessonRequest(
                            request.id,
                            UpdateLessonRequest(status: 'rejected'),
                            user.role,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reddet'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonRequestsState = ref.watch(lessonRequestsProvider);
    final authState = ref.watch(authProvider);
    final isTutor = authState.user?.role == 'tutor';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTutor ? 'Gelen Talepler' : 'Ders Taleplerim'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          
          Expanded(
            child: lessonRequestsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : lessonRequestsState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hata: ${lessonRequestsState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(lessonRequestsProvider.notifier).loadLessonRequests(),
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : lessonRequestsState.lessonRequests.isEmpty
                        ? const Center(
                            child: Text('Henüz ders talebi bulunmuyor'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: lessonRequestsState.lessonRequests.length,
                            itemBuilder: (context, index) {
                              final request = lessonRequestsState.lessonRequests[index];
                              return _buildLessonRequestCard(request, isTutor);
                            },
                          ),
          ),
        ],
      ),
    );
  }
} 