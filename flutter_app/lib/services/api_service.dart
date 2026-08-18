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

  Future<LiveDuaSession?> startLiveDua(String khaniId, String streamType) async {
    final response = await post('/live-dua/start', {
      'khani_id': khaniId,
      'stream_type': streamType,
    });
    if (response['status'] == 'success') {
      return LiveDuaSession.fromJson(response['data']['session']);
    }
    return null;
  }

  Future<LiveDuaSession?> joinLiveDua(String uniqueCode) async {
    final response = await post('/live-dua/join', {
      'unique_code': uniqueCode,
    });
    if (response['status'] == 'success') {
      return LiveDuaSession.fromJson(response['data']['session']);
    }
    return null;
  }

  Future<LiveDuaSession?> getLiveSession(String uniqueCode) async {
    final response = await get('/live-dua/code/$uniqueCode');
    if (response['status'] == 'success') {
      return LiveDuaSession.fromJson(response['data']['session']);
    }
    return null;
  }

  Future<bool> startStream(String uniqueCode, String? streamUrl) async {
    final response = await post('/live-dua/code/$uniqueCode/start', {
      'stream_url': streamUrl ?? '',
    });
    return response['status'] == 'success';
  }

  Future<bool> endLiveDua(String uniqueCode) async {
    final response = await post('/live-dua/code/$uniqueCode/end', {});
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
