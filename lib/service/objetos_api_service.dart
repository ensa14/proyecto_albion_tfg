import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/objetos_model.dart';

class AlbionApiService {
  static const String _dumpUrl =
      'https://cdn.jsdelivr.net/gh/ao-data/ao-bin-dumps@master/items.json';

  static const String _openAlbionWeaponsUrl =
      "https://api.openalbion.com/api/v3/weapons";
  static const String _openAlbionArmorsUrl =
      "https://api.openalbion.com/api/v3/armors";

  /// Regex para armas 1H, 2H y offhand
  final RegExp _weaponRegex = RegExp(r'^T\d+_(MAIN|2H|OFF)_.+');

  /// Regex para armadura, casco, botas y capas
  final RegExp _armorRegex = RegExp(r'^T\d+_(ARMOR|HEAD|SHOES|CAPE)_.+');

  /// Exclusiones (no equipables o sin icono)
  bool _isExcluded(String id) {
    return id.contains('ARTEFACT') ||
        id.contains('TOKEN') ||
        id.contains('TROPHY') ||
        id.contains('SKILLBOOK') ||
        id.contains('JOURNAL') ||
        id.contains('MATERIAL') ||
        id.contains('MOUNT') ||
        id.contains('BAG') ||
        id.contains('FURNITURE') ||
        id.contains('CITY') ||
        id.contains('AVATAR') ||
        id.contains('SKIN') ||
        id.contains('TOTEM') ||
        id.contains('OBJECT') ||
        id.contains('RESOURCE') ||
        id.contains('GATHERER') ||
        id.contains('FARM') ||
        id.contains('CROP') ||
        id.contains('QUESTITEM') ||
        id.contains('LOOTCHEST') ||
        id.contains('FISH') ||
        id.contains('PVP') ||
        id.contains('UNIQUE_HIDEOUT') ||
        id.contains('TEST_') ||
        id.contains('VANITY') ||
        id.contains('UNIQUE_CAPE') ||
        id.contains('FOUNDER') ||
        id.contains('STARTERPACK') ||
        id.contains('ARENA_BANNER');
  }

  bool _isWeapon(String id, String category, String subCat, String craft) {
    return _weaponRegex.hasMatch(id) ||
        (category == 'equipment' &&
            (subCat == 'mainhand' || subCat == 'offhand' || subCat == '2h')) ||
        craft == 'weapon';
  }

  bool _isArmor(String id, String category, String subCat) {
    return _armorRegex.hasMatch(id) ||
        (category == 'equipment' &&
            (subCat == 'armor' ||
                subCat == 'head' ||
                subCat == 'shoes' ||
                subCat == 'cape')) ||
        id.contains('_ARMOR_') ||
        id.contains('_HEAD_') ||
        id.contains('_SHOES_') ||
        id.contains('_CAPE_');
  }

  bool _isConsumable(String id) {
    return id.startsWith('T') &&
        (id.contains('FOOD_') || id.contains('POTION_'));
  }

  // =====================================================
  // 🔥 Cargar mapa de TODOS los IDs reales de OpenAlbion
  // =====================================================
  Future<Map<String, int>> _loadRealIds() async {
    print("🔵 Descargando realId de weapons y armors...");

    final Map<String, int> result = {};

    // --- Weapons ---
    final respWeapons = await http.get(Uri.parse(_openAlbionWeaponsUrl));
    if (respWeapons.statusCode == 200) {
      final data = jsonDecode(respWeapons.body);
      for (var w in data["data"]) {
        final identifier = w["identifier"];
        final id = w["id"];
        if (identifier != null && id is int) {
          result[identifier] = id;
        }
      }
    }

    // --- Armors ---
    final respArmors = await http.get(Uri.parse(_openAlbionArmorsUrl));
    if (respArmors.statusCode == 200) {
      final data = jsonDecode(respArmors.body);
      for (var a in data["data"]) {
        final identifier = a["identifier"];
        final id = a["id"];
        if (identifier != null && id is int) {
          result[identifier] = id;
        }
      }
    }

    print("✔ Identificadores reales cargados: ${result.length}");
    return result;
  }

  // =====================================================
  // CARGA FINAL DE ITEMS
  // =====================================================
  Future<List<Item>> fetchItems() async {
    // 1️⃣ Map realId
    final realIdMap = await _loadRealIds();

    // 2️⃣ Descargar items.json
    final response = await http.get(Uri.parse(_dumpUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar ítems (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);

    Map<String, dynamic>? itemsMap;
    if (decoded is Map<String, dynamic>) {
      itemsMap = decoded.containsKey('items') ? decoded['items'] : decoded;
    }

    if (itemsMap == null || itemsMap.isEmpty) {
      throw Exception('❌ items.json vacío');
    }

    final List<Map<String, dynamic>> rawItems = [];

    // Aplanar estructura
    for (final value in itemsMap.values) {
      if (value is Map<String, dynamic>) {
        rawItems.add(value);
      } else if (value is List) {
        for (final sub in value) {
          if (sub is Map<String, dynamic>) rawItems.add(sub);
        }
      }
    }

    // 🔥 3️⃣ Filtrado + asignación de realId
    List<Item> items = rawItems.where((e) {
      final rawId = (e['UniqueName'] ??
              e['@uniquename'] ??
              e['uniquename'] ??
              e['Id'] ??
              e['id'])
          ?.toString();

      if (rawId == null || rawId.isEmpty) return false;

      final id = rawId.toUpperCase();
      if (_isExcluded(id)) return false;

      final category =
          (e['ShopCategory'] ?? e['@shopcategory'] ?? '').toString().toLowerCase();

      final subCat =
          (e['ShopSubCategory1'] ?? e['@shopsubcategory1'] ?? '')
              .toString()
              .toLowerCase();

      final craft =
          (e['@craftingcategory'] ?? e['craftingcategory'] ?? '')
              .toString()
              .toLowerCase();

      return _isWeapon(id, category, subCat, craft) ||
          _isArmor(id, category, subCat) ||
          _isConsumable(id);
    }).map((e) {
      final item = Item.fromJson(e);

      // 4️⃣ Asignar ID real si existe
      item.realId = realIdMap[item.identifier] ?? 0;

      return item;
    }).toList();

    print("🔎 Ítems finales cargados: ${items.length}");
    return items;
  }
}
