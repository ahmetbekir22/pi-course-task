import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_request.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

final lessonRequestsProvider = StateNotifierProvider<LessonRequestsNotifier, LessonRequestsState>((ref) {
  return LessonRequestsNotifier(ref.read(apiClientProvider));
});

class LessonRequestsState {
  final List<LessonRequest> lessonRequests;
  final bool isLoading;
  final String? error;
  final String? statusFilter;

  LessonRequestsState({
    this.lessonRequests = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter,
  });

  LessonRequestsState copyWith({
    List<LessonRequest>? lessonRequests,
    bool? isLoading,
    String? error,
    String? statusFilter,
  }) {
    return LessonRequestsState(
      lessonRequests: lessonRequests ?? this.lessonRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class LessonRequestsNotifier extends StateNotifier<LessonRequestsState> {
  final ApiClient _apiClient;

  LessonRequestsNotifier(this._apiClient) : super(LessonRequestsState());

  Future<void> loadLessonRequests({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiClient.getLessonRequests(status: status);
      final List<dynamic> results = response['results'];
      final lessonRequests = results.map((json) => LessonRequest.fromJson(json)).toList();
      
      state = state.copyWith(
        lessonRequests: lessonRequests,
        isLoading: false,
        statusFilter: status,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createLessonRequest(CreateLessonRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiClient.createLessonRequest(request);
      // Reload the list after creating
      await loadLessonRequests(status: state.statusFilter);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateLessonRequest(int id, UpdateLessonRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiClient.updateLessonRequest(id, request);
      // Reload the list after updating
      await loadLessonRequests(status: state.statusFilter);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 