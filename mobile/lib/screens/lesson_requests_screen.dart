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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    final padding = screenWidth * 0.04;
    final spacing = screenHeight * 0.01;
    final fontSize = screenWidth * 0.035;
    
    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Durum Filtresi:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
          SizedBox(height: spacing),
          Wrap(
            spacing: spacing * 2,
            children: [
              FilterChip(
                label: Text('Tümü', style: TextStyle(fontSize: fontSize * 0.9)),
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
                label: Text('Beklemede', style: TextStyle(fontSize: fontSize * 0.9)),
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
                label: Text('Onaylandı', style: TextStyle(fontSize: fontSize * 0.9)),
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
                label: Text('Reddedildi', style: TextStyle(fontSize: fontSize * 0.9)),
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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    final margin = screenHeight * 0.02;
    final padding = screenWidth * 0.04;
    final spacing = screenHeight * 0.01;
    final iconSize = screenWidth * 0.04;
    final fontSize = screenWidth * 0.035;
    final statusPadding = screenWidth * 0.02;
    final buttonSpacing = screenWidth * 0.02;
    
    return Card(
      margin: EdgeInsets.only(bottom: margin),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ders Talebi #${request.id}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: statusPadding, vertical: statusPadding * 0.5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(statusPadding * 1.5),
                  ),
                  child: Text(
                    _getStatusText(request.status),
                    style: TextStyle(color: Colors.white, fontSize: fontSize * 0.8),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing * 1.5),
            
            // Subject and DateTime
            Row(
              children: [
                Icon(Icons.subject, size: iconSize, color: Colors.grey[600]),
                SizedBox(width: spacing * 2),
                Text(
                  'Konu: ${request.subject?.name ?? 'Bilinmiyor'}',
                  style: TextStyle(fontSize: fontSize * 0.9),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: iconSize, color: Colors.grey[600]),
                SizedBox(width: spacing * 2),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(request.startTime),
                  style: TextStyle(fontSize: fontSize * 0.9),
                ),
              ],
            ),
            
            SizedBox(height: spacing * 2),
            
            // Duration
            Row(
              children: [
                Icon(Icons.timer, size: iconSize, color: Colors.grey[600]),
                SizedBox(width: spacing * 2),
                Text(
                  '${request.durationMinutes} dakika',
                  style: TextStyle(fontSize: fontSize * 0.9),
                ),
              ],
            ),
            
            if (request.note != null && request.note!.isNotEmpty) ...[
              SizedBox(height: spacing * 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: iconSize, color: Colors.grey[600]),
                  SizedBox(width: spacing * 2),
                  Expanded(
                    child: Text(
                      'Not: ${request.note}',
                      style: TextStyle(color: Colors.grey[600], fontSize: fontSize * 0.9),
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: spacing * 1.5),
            
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
                      child: Text('Onayla', style: TextStyle(fontSize: fontSize * 0.9)),
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
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
                      child: Text('Reddet', style: TextStyle(fontSize: fontSize * 0.9)),
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
    
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    final padding = screenWidth * 0.06;
    final spacing = screenHeight * 0.02;
    final largeSpacing = screenHeight * 0.03;
    final iconSize = screenWidth * 0.16;
    final fontSize = screenWidth * 0.04;
    final smallFontSize = screenWidth * 0.035;
    final listPadding = screenWidth * 0.04;

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
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: iconSize,
                                color: Colors.orange.shade600,
                              ),
                              SizedBox(height: spacing),
                              Text(
                                lessonRequestsState.error!,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: fontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: largeSpacing),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final user = ref.read(authProvider).user;
                                  if (user != null) {
                                    ref.read(lessonRequestsProvider.notifier).loadLessonRequests(role: user.role);
                                  }
                                },
                                icon: const Icon(Icons.refresh),
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
                    : lessonRequestsState.lessonRequests.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(padding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: iconSize,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: spacing),
                                  Text(
                                    isTutor 
                                        ? 'Henüz gelen ders talebi bulunmuyor'
                                        : 'Henüz ders talebi oluşturmadınız',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: fontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  Text(
                                    isTutor
                                        ? 'Öğrenciler ders talebi oluşturduğunda burada görünecek'
                                        : 'Eğitmen bulup ders talebi oluşturabilirsiniz',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: smallFontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(listPadding),
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