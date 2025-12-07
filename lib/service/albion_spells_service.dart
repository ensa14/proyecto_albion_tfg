import 'dart:convert';
import 'package:http/http.dart' as http;

class AlbionSpellsService {
  static Future<List<dynamic>> getSpells(int index) async {
    final url =
        Uri.parse("https://api.openalbion.com/api/v3/weapon-stats/weapon/$index");

    final res = await http.get(url);

    if (res.statusCode != 200) {
      return [];
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map && decoded.containsKey("data")) {
      return decoded["data"];
    }

    return [];
  }
}
