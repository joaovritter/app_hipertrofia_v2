import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../models/onboarding_models.dart';
import '../models/exercise.dart';
import '../models/workout_history.dart';
class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Auth
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return response.data;
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Training Setup / Onboarding
  Future<List<MuscleGroup>> getMuscleGroups() async {
    try {
      final response = await _dio.get('/training/muscle-groups');
      return (response.data as List).map((e) => MuscleGroup.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Exercise>> getAllExercises() async {
    try {
      final response = await _dio.get('/training/exercises');
      return (response.data as List).map((e) => Exercise.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setupTraining(List<TrainingDivision> divisions) async {
    try {
      await _dio.post('/training/setup', data: {
        'divisions': divisions.where((d) => !d.isRest).map((d) => d.toJson()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Training
  Future<WorkoutSession> getDailySession({int offset = 0}) async {
    try {
      final response = await _dio.get('/training/session', queryParameters: {'offset': offset});
      return WorkoutSession.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Workouts
  Future<Map<String, dynamic>> finishWorkout(int sessionId, String sessionName, List<WorkoutSet> sets) async {
    try {
      final response = await _dio.post('/workouts/session/$sessionId/finish', data: {
        'sessionName': sessionName,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'sets': sets.map((s) => s.toJson()).toList(),
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<WorkoutHistoryDetail> getWorkoutHistoryDetail(int id) async {
    try {
      final response = await _dio.get('/workouts/session/$id');
      return WorkoutHistoryDetail.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getWorkoutHistory({int? month, int? year}) async {
    try {
      final response = await _dio.get('/workouts/calendar', queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.data['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
