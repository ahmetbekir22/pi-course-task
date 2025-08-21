import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final request = LoginRequest(email: email, password: password);
      await _apiClient.login(request);
      await _loadUser(); // Load user after successful login
    } on DioException catch (e) {
      String errorMessage = 'Giriş yapılamadı';
      
      if (e.response?.statusCode == 400) {
        // Backend validation error
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('email')) {
            errorMessage = 'E-posta adresi geçersiz';
          } else if (data.containsKey('password')) {
            errorMessage = 'Şifre geçersiz';
          } else if (data.containsKey('non_field_errors')) {
            errorMessage = 'E-posta veya şifre hatalı';
          } else {
            errorMessage = 'Giriş bilgileri hatalı';
          }
        }
      } else if (e.response?.statusCode == 401) {
        // Check for specific error message from backend
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('detail')) {
          final detail = data['detail'] as String;
          if (detail.contains('No active account found')) {
            errorMessage = 'E-posta veya şifre hatalı';
          } else {
            errorMessage = detail;
          }
        } else {
          errorMessage = 'E-posta veya şifre hatalı';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Bağlantı zaman aşımı';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Sunucuya bağlanılamıyor';
      }
      
      state = state.copyWith(
        error: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Beklenmeyen bir hata oluştu',
      );
    } finally {
      // Always stop loading spinner
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> register(String email, String password, String role, {String? firstName, String? lastName}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 1) Try register
      final request = RegisterRequest(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );
      await _apiClient.register(request);
      
      // 2) If register succeeded, try auto-login
      try {
        await login(email, password);
      } catch (loginError) {
        // If auto-login fails, show success message but don't auto-login
        state = state.copyWith(
          isLoading: false,
          error: 'Kayıt başarılı! Lütfen giriş yapın.',
        );
      }
    } on DioException catch (e) {
      // Map register-time errors
      String errorMessage = 'Kayıt olunamadı';
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('email')) {
            final emailErrors = data['email'] as List?;
            if (emailErrors != null && emailErrors.isNotEmpty) {
              errorMessage = emailErrors.first.toString();
            } else {
              errorMessage = 'E-posta adresi geçersiz';
            }
          } else if (data.containsKey('password')) {
            final passwordErrors = data['password'] as List?;
            if (passwordErrors != null && passwordErrors.isNotEmpty) {
              errorMessage = passwordErrors.first.toString();
            } else {
              errorMessage = 'Şifre geçersiz';
            }
          } else if (data.containsKey('role')) {
            errorMessage = 'Geçersiz rol seçimi';
          } else if (data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          } else {
            errorMessage = 'Kayıt bilgileri hatalı';
          }
        }
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'Bu e-posta adresi zaten kayıtlı';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Bağlantı zaman aşımı';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Sunucuya bağlanılamıyor';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Kayıt sırasında beklenmeyen bir hata oluştu',
      );
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _apiClient.getMe();
      state = state.copyWith(user: user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired or invalid, clear tokens
        await _apiClient.logout();
        state = state.copyWith(
          error: 'Oturum süresi doldu, lütfen tekrar giriş yapın',
        );
      } else {
        state = state.copyWith(
          error: 'Kullanıcı bilgileri yüklenemedi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Beklenmeyen bir hata oluştu',
      );
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
    state = AuthState(); // Clear user state on logout
  }

  Future<void> updateProfile({
    String? gradeLevel,
    String? bio,
    int? hourlyRate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final request = UpdateProfileRequest(
        gradeLevel: gradeLevel,
        bio: bio,
        hourlyRate: hourlyRate,
      );
      final updatedUser = await _apiClient.updateProfile(request);
      state = state.copyWith(user: updatedUser);
    } on DioException catch (e) {
      String errorMessage = 'Profil güncellenemedi';
      
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('grade_level')) {
            errorMessage = 'Sınıf seviyesi geçersiz';
          } else if (data.containsKey('bio')) {
            errorMessage = 'Biyografi geçersiz';
          } else if (data.containsKey('hourly_rate')) {
            errorMessage = 'Saatlik ücret geçersiz';
          }
        }
      }
      
      state = state.copyWith(
        error: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Beklenmeyen bir hata oluştu',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 