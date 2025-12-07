import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/spell_model.dart';

class SpellsApiService {
  static const base = "https://api.openalbion.com/api/v3";

  double parseNumber(dynamic value) {
    if (value == null) return 0;
    final str = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    if (str.isEmpty) return 0;
    return double.tryParse(str) ?? 0;
  }

  Future<List<Spell>> loadSpellsByRealId(int id) async {
    final url = Uri.parse("$base/spells/weapon/$id");

    print("🔵 Consultando spells por ID real → $url");

    final resp = await http.get(url);

    if (resp.statusCode != 200) {
      print("⚠️ Error API spells: status ${resp.statusCode}");
      return [];
    }

    final jsonData = json.decode(resp.body);

    if (jsonData["data"] == null) {
      print("⚠️ Spells vacíos para ID $id");
      return [];
    }

    final List groups = jsonData["data"];
    List<Spell> spells = [];

    for (var group in groups) {
      final slot = group["slot"]?.toString() ?? "";

      for (var s in group["spells"] ?? []) {
        spells.add(
          Spell(
            id: s["id"] ?? 0,
            name: s["name"] ?? "",
            slot: slot,
            icon: s["icon"] ?? "",
            description: s["description"] ?? "",
            cooldown: parseNumber(
              s["attributes"]?.firstWhere(
                (a) => a["name"] == "Cooldown",
                orElse: () => {"value": "0"},
              )["value"],
            ),
            energyCost: parseNumber(
              s["attributes"]?.firstWhere(
                (a) => a["name"] == "Energy Cost",
                orElse: () => {"value": "0"},
              )["value"],
            ),
          ),
        );
      }
    }

    print("✅ Spells cargados: ${spells.length} para ID real $id");
    return spells;
  }
}
