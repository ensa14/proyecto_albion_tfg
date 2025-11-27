import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../common/constantes.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();

  // ================================
  // GUARDAR TOKEN
  // ================================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: "apiToken", value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: "apiToken");
  }

  static Future<void> logout() async {
    await _storage.delete(key: "apiToken");
  }

  // ================================
  // REGISTER
  // ================================
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  }) async {
    final url = Uri.parse("${AppConstants.baseUrl}register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "email": email,
        "password": password,
        "telefono": telefono,
      }),
    );

    return jsonDecode(response.body);
  }

  // ================================
  // LOGIN
  // ================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("${AppConstants.baseUrl}login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  // ================================
  // GET /me (ruta protegida)
  // ================================
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse("${AppConstants.baseUrl}me");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
