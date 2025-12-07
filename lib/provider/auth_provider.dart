import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constantes.dart'; //archivo con variables que pueden cambiar (ejemplo url, ais solo lo tengo que cambiar una vez)

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  final String baseUrl = AppConstants.baseUrl; 

  // ===========================================================
  // CARGAR TOKEN GUARDADO
  // ===========================================================
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString("token");

    if (savedToken != null) {
      _token = savedToken;
      await fetchUserData();
    }
  }

  // ===========================================================
  // LOGIN
  // ===========================================================
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );


      print("LOGIN PAYLOAD → email: $email , password: $password");
      print("URL LOGIN → $baseUrl/login");
      print("STATUS CODE → ${response.statusCode}");
      print("BODY → ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _token = data["token"];
      _user = data["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);

      notifyListeners();
      return true;
    }

    return false;
  }

  // ===========================================================
  // REGISTRO
  // ===========================================================
  Future<bool> register(
      String nombre, String email, String password, String telefono) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "email": email,
        "password": password,
        "telefono": telefono
      }),
    );

      print("REGISTER RESPONSE STATUS: ${response.statusCode}");
      print("REGISTER RESPONSE BODY: ${response.body}");
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);


      _token = data["token"];
      _user = data["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);

      notifyListeners();

    
      return true;
    }

    return false;
  }

  // ===========================================================
  // OBTENER DATOS DEL USUARIO (TOKEN)
  // ===========================================================
  Future<void> fetchUserData() async {
    if (_token == null) return;

    final url = Uri.parse("$baseUrl/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $_token"
      },
    );

    if (response.statusCode == 200) {
      _user = jsonDecode(response.body);
      notifyListeners();
    }
  }

  // ===========================================================
  // LOGOUT
  // ===========================================================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    _token = null;
    _user = null;

    notifyListeners();
  }
}
