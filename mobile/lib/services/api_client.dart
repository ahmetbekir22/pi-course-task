import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../models/subject.dart';
import '../models/lesson_request.dart';

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8001/api';
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Only handle 401
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;

          // Do not attempt refresh on auth endpoints or if already retried
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/refresh');
          final alreadyRetried = error.requestOptions.extra['retried'] == true;

          if (isAuthEndpoint || alreadyRetried) {
            handler.next(error);
            return;
          }

          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken == null || refreshToken.isEmpty) {
            handler.next(error);
            return;
          }

          try {
            // Use a clean Dio instance without interceptors to avoid recursion
            final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
            final response = await refreshDio.post('/auth/refresh', data: {
              'refresh': refreshToken,
            });
            final newToken = response.data['access'] as String;
            await _storage.write(key: 'access_token', value: newToken);

            // Retry original request with new token
            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newToken';
            requestOptions.extra['retried'] = true;

            final retryResponse = await _dio.fetch(requestOptions);
            handler.resolve(retryResponse);
            return;
          } catch (e) {
            // Refresh failed -> clear tokens and propagate original error
            await _storage.deleteAll();
            handler.next(error);
            return;
          }
        }

        // Not a 401, continue
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post('/auth/login', data: request.toJson());
    final loginResponse = LoginResponse.fromJson(response.data);
    
    // Store tokens
    await _storage.write(key: 'access_token', value: loginResponse.access);
    await _storage.write(key: 'refresh_token', value: loginResponse.refresh);
    
    return loginResponse;
  }

  Future<User> register(RegisterRequest request) async {
    final response = await _dio.post('/auth/register', data: request.toJson());
    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // User endpoints
  Future<User> getMe() async {
    final response = await _dio.get('/me');
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(UpdateProfileRequest request) async {
    final response = await _dio.patch('/me', data: request.toJson());
    return User.fromJson(response.data);
  }

  // Subjects
  Future<List<Subject>> getSubjects() async {
    final response = await _dio.get('/subjects');
    final List<dynamic> results = response.data['results'];
    return results.map((json) => Subject.fromJson(json)).toList();
  }

  // Tutors
  Future<Map<String, dynamic>> getTutors({
    int? subjectId,
    String? search,
    String? ordering,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (subjectId != null) queryParams['subject'] = subjectId;
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _dio.get('/tutors', queryParameters: queryParams);
    return response.data;
  }

  Future<User> getTutorDetail(int id) async {
    final response = await _dio.get('/tutors/$id');
    return User.fromJson(response.data);
  }

  // Lesson requests
  Future<Map<String, dynamic>> getLessonRequests({
    String? role,
    String? status,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (role != null) queryParams['role'] = role;
    if (status != null) queryParams['status'] = status;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _dio.get('/lesson-requests', queryParameters: queryParams);
    return response.data;
  }

  Future<LessonRequest> createLessonRequest(CreateLessonRequest request) async {
    final response = await _dio.post('/lesson-requests', data: request.toJson());
    return LessonRequest.fromJson(response.data);
  }

  Future<LessonRequest> updateLessonRequest(int id, UpdateLessonRequest request) async {
    final response = await _dio.patch('/lesson-requests/$id', data: request.toJson());
    return LessonRequest.fromJson(response.data);
  }
} 