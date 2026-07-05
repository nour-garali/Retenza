import 'package:dio/dio.dart';
import 'api_client.dart';

class AdminService {
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final res = await apiClient.get('/admin/statistics');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des statistiques');
    }
  }

  static Future<List<dynamic>> getCommerces({String? status}) async {
    try {
      final res = await apiClient.get('/admin/commerces', queryParameters: {
        if (status != null) 'status': status,
        'limit': 100,
      });
      return res.data['data']['commerces'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des commerces');
    }
  }

  static Future<List<dynamic>> getClients() async {
    try {
      final res = await apiClient.get('/admin/clients', queryParameters: {
        'limit': 100,
      });
      return res.data['data']['clients'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des clients');
    }
  }
  
  static Future<void> approveCommerce(String id) async {
    try {
      await apiClient.patch('/admin/commerces/$id/activate');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur d\'approbation');
    }
  }

  static Future<void> rejectCommerce(String id) async {
    try {
      await apiClient.delete('/admin/commerces/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de rejet');
    }
  }
}
