import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/subject.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

// Model for tutor list items (simplified from backend response)
class TutorListItem {
  final int id;
  final String name;
  final String? bio;
  final int hourlyRate;
  final double? rating;
  final List<Subject> subjects;

  TutorListItem({
    required this.id,
    required this.name,
    this.bio,
    required this.hourlyRate,
    this.rating,
    required this.subjects,
  });

  factory TutorListItem.fromJson(Map<String, dynamic> json) {
    return TutorListItem(
      id: json['id'],
      name: json['name'] ?? 'İsimsiz Eğitmen',
      bio: json['bio'],
      hourlyRate: json['hourly_rate'],
      rating: json['rating'] != null ? json['rating'].toDouble() : null,
      subjects: (json['subjects'] as List)
          .map((subjectJson) => Subject.fromJson(subjectJson))
          .toList(),
    );
  }
}

final tutorsProvider = StateNotifierProvider<TutorsNotifier, TutorsState>((ref) {
  return TutorsNotifier(ref.read(apiClientProvider));
});

class TutorsState {
  final List<TutorListItem> tutors;
  final bool isLoading;
  final String? error;
  final int? selectedSubjectId;
  final String searchQuery;
  final String ordering;

  TutorsState({
    this.tutors = const [],
    this.isLoading = false,
    this.error,
    this.selectedSubjectId,
    this.searchQuery = '',
    this.ordering = '-rating',
  });

  TutorsState copyWith({
    List<TutorListItem>? tutors,
    bool? isLoading,
    String? error,
    int? selectedSubjectId,
    String? searchQuery,
    String? ordering,
  }) {
    return TutorsState(
      tutors: tutors ?? this.tutors,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      searchQuery: searchQuery ?? this.searchQuery,
      ordering: ordering ?? this.ordering,
    );
  }
}

class TutorsNotifier extends StateNotifier<TutorsState> {
  final ApiClient _apiClient;

  TutorsNotifier(this._apiClient) : super(TutorsState());

  Future<void> loadTutors({
    int? subjectId,
    String? search,
    String? ordering,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiClient.getTutors(
        subjectId: subjectId,
        search: search,
        ordering: ordering,
      );
      
      final List<dynamic> results = response['results'];
      final tutors = results.map((json) => TutorListItem.fromJson(json)).toList();
      
      state = state.copyWith(
        tutors: tutors,
        isLoading: false,
        selectedSubjectId: subjectId,
        searchQuery: search ?? '',
        ordering: ordering ?? '-rating',
      );
    } catch (e) {
      String errorMessage = 'Eğitmenler yüklenemedi';
      
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

  void updateFilters({
    int? subjectId,
    String? search,
    String? ordering,
  }) {
    loadTutors(
      subjectId: subjectId ?? state.selectedSubjectId,
      search: search ?? state.searchQuery,
      ordering: ordering ?? state.ordering,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 