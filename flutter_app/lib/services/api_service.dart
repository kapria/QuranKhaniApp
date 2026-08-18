import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _handleResponse(response);
  }

  Future<dynamic> postOAuth(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: const {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Khani?> startKhani(String khaniId) async {
    final response = await post('/khanis/$khaniId/start', {});
    if (response['status'] == 'success') {
      return Khani.fromJson(response['data']['khani']);
    }
    return null;
  }

  Future<Khani?> joinKhani(String joinCode) async {
    final response = await post('/khanis/join', {
      'join_code': joinCode,
    });
    if (response['status'] == 'success') {
      return Khani.fromJson(response['data']['khani']);
    }
    return null;
  }

  Future<Khani?> getKhaniByCode(String joinCode) async {
    final response = await get('/khanis/code/$joinCode');
    if (response['status'] == 'success') {
      return Khani.fromJson(response['data']['khani']);
    }
    return null;
  }

  Future<LiveDuaSession?> startLiveDua(String joinCode, String streamType) async {
    final response = await post('/live-dua/start', {
      'join_code': joinCode,
      'stream_type': streamType,
    });
    if (response['status'] == 'success') {
      return LiveDuaSession.fromJson(response['data']['session']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> joinLiveDua(String joinCode) async {
    final response = await post('/live-dua/join', {
      'join_code': joinCode,
    });
    if (response['status'] == 'success') {
      return response['data'];
    }
    return null;
  }

  Future<LiveDuaSession?> getLiveSessionByCode(String joinCode) async {
    final response = await get('/live-dua/code/$joinCode');
    if (response['status'] == 'success') {
      return LiveDuaSession.fromJson(response['data']['liveSession'] ?? {});
    }
    return null;
  }

  Future<bool> startStream(String joinCode, String? streamUrl, String streamType) async {
    final response = await post('/live-dua/code/$joinCode/start', {
      'stream_url': streamUrl ?? '',
      'stream_type': streamType,
    });
    return response['status'] == 'success';
  }

  Future<bool> endLiveDua(String joinCode) async {
    final response = await post('/live-dua/code/$joinCode/end', {});
    return response['status'] == 'success';
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await get('/notifications');
    if (response['status'] == 'success') {
      final List list = response['data']['notifications'] ?? [];
      return list.map((n) => NotificationModel.fromJson(n)).toList();
    }
    return [];
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await get('/notifications');
    if (response['status'] == 'success') {
      return response['data']['unread_count'] ?? 0;
    }
    return 0;
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final response = await patch('/notifications/$notificationId/read', {});
    return response['status'] == 'success';
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'API request failed');
    }
  }
}
