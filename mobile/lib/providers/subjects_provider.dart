import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/subject.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>((ref) {
  return SubjectsNotifier(ref.read(apiClientProvider));
});

class SubjectsState {
  final List<Subject> subjects;
  final bool isLoading;
  final String? error;

  SubjectsState({
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  SubjectsState copyWith({
    List<Subject>? subjects,
    bool? isLoading,
    String? error,
  }) {
    return SubjectsState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SubjectsNotifier extends StateNotifier<SubjectsState> {
  final ApiClient _apiClient;

  SubjectsNotifier(this._apiClient) : super(SubjectsState());

  Future<void> loadSubjects() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final subjects = await _apiClient.getSubjects();
      state = state.copyWith(subjects: subjects, isLoading: false);
    } catch (e) {
      String errorMessage = 'Konular yüklenemedi';
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Bağlantı zaman aşımı';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Sunucuya bağlanılamıyor';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Oturum süresi doldu, lütfen tekrar giriş yapın';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Sunucu hatası, lütfen daha sonra tekrar deneyin';
        }
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 