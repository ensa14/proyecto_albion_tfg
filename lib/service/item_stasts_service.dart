import 'dart:convert';
import 'package:http/http.dart' as http;

class AlbionItemStatsService {
  static const base = "https://api.openalbion.com/api/v3";

  Future<List<Map<String, String>>> getItemStats(int realId, String type) async {
    // type: weapon, armor, shoes, head, cape, offhand
    final url = Uri.parse("$base/$type-stats/$type/$realId");

    print("📌 Cargando stats: $url");

    final resp = await http.get(url);

    if (resp.statusCode != 200) {
      print("❌ API stats error ${resp.statusCode}");
      return [];
    }

    final data = json.decode(resp.body);

    if (data["data"] == null) return [];

    // Tomamos la primera variante (enchantment 0)
    final statsList = data["data"][0]["stats"][0]["stats"] as List;

    return statsList
        .map((s) => {
              "name": s["name"].toString(),
              "value": s["value"].toString(),
            })
        .toList();
  }
}
