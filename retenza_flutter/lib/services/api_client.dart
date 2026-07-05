import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
//  API CLIENT
//  Configuration centralisée de Dio pour les requêtes backend
// ══════════════════════════════════════════════════════════════

class ApiClient {
  // L'adresse IP de votre ordinateur sur le réseau Wi-Fi local
  static const String baseUrl = 'http://192.168.0.171:3000/api'; 
  
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Intercepteur pour ajouter le token JWT à chaque requête
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Gestion globale des erreurs si besoin (ex: token expiré)
          return handler.next(e);
        },
      ),
    );
  }
}

// Instance globale singleton pour simplifier l'accès
final apiClient = ApiClient().dio;
