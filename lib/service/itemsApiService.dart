import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemsApiService {
  static const base = "https://api.openalbion.com/api/v3";

  /// Busca un ID real por identifier usando weapons y armors
  Future<int?> getRealItemId(String identifier) async {
    if (identifier.isEmpty) return null;

    // 1) Buscar en armas
    final idWeapon = await _searchInEndpoint("/weapons", identifier);
    if (idWeapon != null) return idWeapon;

    // 2) Buscar en armaduras
    final idArmor = await _searchInEndpoint("/armors", identifier);
    if (idArmor != null) return idArmor;

    print("❌ No se encontró realId para $identifier");
    return null;
  }

  /// Función privada que busca en un endpoint concreto
  Future<int?> _searchInEndpoint(String endpoint, String identifier) async {
    final url = Uri.parse("$base$endpoint");

    final resp = await http.get(url);
    if (resp.statusCode != 200) return null;

    final data = json.decode(resp.body);
    final List items = data["data"];

    final item = items.firstWhere(
      (x) => x["identifier"] == identifier,
      orElse: () => null,
    );

    if (item == null) return null;

    return item["id"];   // ← ID REAL válido para pedir spells
  }
}
