import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_request.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';
import 'package:dio/dio.dart';

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

  Future<void> loadLessonRequests({String? status, String? role}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiClient.getLessonRequests(status: status, role: role);
      final List<dynamic> results = response['results'];
      final lessonRequests = results.map((json) => LessonRequest.fromJson(json)).toList();
      
      state = state.copyWith(
        lessonRequests: lessonRequests,
        isLoading: false,
        statusFilter: status,
      );
    } catch (e) {
      String errorMessage = 'Ders talepleri yüklenemedi';
      
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

  Future<void> createLessonRequest(CreateLessonRequest request, String userRole) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('Creating lesson request: ${request.toJson()}');
      await _apiClient.createLessonRequest(request);
      print('Lesson request created successfully');
      // Reload the list after creating
      await loadLessonRequests(status: state.statusFilter, role: userRole);
    } catch (e) {
      print('Error creating lesson request: $e');
      String errorMessage = 'Ders talebi oluşturulamadı';
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Bağlantı zaman aşımı';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Sunucuya bağlanılamıyor';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Geçersiz bilgi, lütfen kontrol edin';
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

  Future<void> updateLessonRequest(int id, UpdateLessonRequest request, String userRole) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiClient.updateLessonRequest(id, request);
      // Reload the list after updating
      await loadLessonRequests(status: state.statusFilter, role: userRole);
    } catch (e) {
      String errorMessage = 'Ders talebi güncellenemedi';
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Bağlantı zaman aşımı';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Sunucuya bağlanılamıyor';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Geçersiz bilgi, lütfen kontrol edin';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Oturum süresi doldu, lütfen tekrar giriş yapın';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Bu işlem için yetkiniz yok';
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