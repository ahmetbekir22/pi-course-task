import 'package:flutter_riverpod/flutter_riverpod.dart';
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