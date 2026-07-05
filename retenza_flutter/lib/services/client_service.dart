import 'package:dio/dio.dart';
import 'api_client.dart';

// ══════════════════════════════════════════════════════════════
//  CLIENT SERVICE
//  Gestion des appels API spécifiques aux clients (Tableau de bord, etc.)
// ══════════════════════════════════════════════════════════════

class ClientService {
  /// Récupère les données du tableau de bord du client
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await apiClient.get('/clients/dashboard');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la récupération du tableau de bord');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur serveur');
      }
      throw Exception('Erreur de connexion au serveur');
    }
  }
}
