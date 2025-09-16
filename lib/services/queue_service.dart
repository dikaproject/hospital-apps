import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart';

class QueueService {
  
  // Get active queue
  static Future<Map<String, dynamic>?> getActiveQueue() async {
    try {
      final response = await HttpService.get(
        '/api/queues/active',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting active queue: $e');
      return null;
    }
  }

  // Get queue details
  static Future<Map<String, dynamic>?> getQueueDetails(String queueId) async {
    try {
      final response = await HttpService.get(
        '/api/queues/$queueId',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      throw Exception('Failed to get queue details');
    } catch (e) {
      print('❌ Error getting queue details: $e');
      throw Exception('Failed to get queue details: $e');
    }
  }

  // Cancel queue
  static Future<bool> cancelQueue(String queueId, {String? reason}) async {
    try {
      final response = await HttpService.patch(
        '/api/queues/$queueId/cancel',
        {'reason': reason},
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error cancelling queue: $e');
      return false;
    }
  }
}