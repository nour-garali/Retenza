import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.getStatistics();
});

final adminCommercesProvider = FutureProvider<List<dynamic>>((ref) async {
  return await AdminService.getCommerces(status: 'active');
});

final adminPendingProvider = FutureProvider<List<dynamic>>((ref) async {
  return await AdminService.getCommerces(status: 'pending');
});

final adminClientsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await AdminService.getClients();
});
