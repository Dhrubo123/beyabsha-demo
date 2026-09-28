import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  static const _tokenKey = 'apiToken';
  final http.Client _client;
  String? _token;

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token?.isNotEmpty == true;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request('GET', path, query: query);
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    if (_token == null) await hasToken();
    final clean = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$baseUrl/$clean').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, '$value')),
    );
    final response = await _client
        .get(uri, headers: {
          'Accept': 'application/pdf',
          if (_token != null) 'Authorization': 'Bearer $_token',
        })
        .timeout(const Duration(seconds: 30));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    if (response.statusCode == 401) await clearToken();
    throw ApiException(
      'PDF ডাউনলোড করা যায়নি (${response.statusCode})।',
      statusCode: response.statusCode,
    );
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    if (_token == null) await hasToken();
    final clean = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$baseUrl/$clean').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, '$value')),
    );
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    try {
      final response = method == 'GET'
          ? await _client
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 20))
          : await _client
                .post(uri, headers: headers, body: jsonEncode(body ?? const {}))
                .timeout(const Duration(seconds: 20));
      dynamic decoded;
      if (response.body.isNotEmpty) decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      if (response.statusCode == 401) await clearToken();
      final map = decoded is Map ? decoded : const {};
      final errors = map['errors'];
      final firstError = errors is Map && errors.isNotEmpty
          ? (errors.values.first as List?)?.first
          : null;
      throw ApiException(
        '${firstError ?? map['message'] ?? 'Request failed (${response.statusCode})'}',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। API চালু আছে কিনা এবং API URL সঠিক কিনা দেখুন।',
      );
    }
  }
}
