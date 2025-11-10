import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/objetos_model.dart';

class AlbionApiService {
  static const String _baseUrl =
      'https://cdn.jsdelivr.net/gh/ao-data/ao-bin-dumps@master/items.json';

  final _weaponNameRegex = RegExp(r'^T\d+_(MAIN|2H|OFF)_.+'); // patrón armas
  final _armorNameRegex = RegExp(r'^T\d+_(ARMOR|HEAD|SHOES|CAPE)_.+'); // patrón equipamiento

  Future<List<Item>> fetchItems() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar los ítems (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    Map<String, dynamic>? itemsMap;

    if (decoded is Map<String, dynamic>) {
      itemsMap = decoded.containsKey('items')
          ? decoded['items'] as Map<String, dynamic>?
          : decoded;
    }
    if (itemsMap == null || itemsMap.isEmpty) {
      throw Exception('No se encontraron ítems válidos en el JSON');
    }

    // Aplanar los datos
    final List<Map<String, dynamic>> data = [];
    for (final value in itemsMap.values) {
      if (value is Map<String, dynamic>) data.add(value);
      if (value is List) {
        for (final sub in value) {
          if (sub is Map<String, dynamic>) data.add(sub);
        }
      }
    }

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
          id.contains('CITYFACTION'); // excluye ítems de ciudad
    }

    List<Item> items = data.where((e) {
      final rawId = (e['UniqueName'] ??
              e['@uniquename'] ??
              e['uniquename'] ??
              e['Id'] ??
              e['id'])
          ?.toString();
      if (rawId == null || rawId.isEmpty) return false;

      final id = rawId.toUpperCase();
      if (_isExcluded(id)) return false;

      final category = (e['ShopCategory'] ??
              e['@shopcategory'] ??
              e['shopcategory'] ??
              '')
          .toString()
          .toLowerCase();

      final subcat1 = (e['ShopSubCategory1'] ??
              e['@shopsubcategory1'] ??
              e['shopsubcategory1'] ??
              '')
          .toString()
          .toLowerCase();

      final crafting = (e['@craftingcategory'] ??
              e['craftingcategory'] ??
              '')
          .toString()
          .toLowerCase();

      // 🔹 Armas
      final isWeapon = _weaponNameRegex.hasMatch(id) ||
          (category == 'equipment' &&
              (subcat1 == 'mainhand' ||
                  subcat1 == 'offhand' ||
                  subcat1 == '2h')) ||
          crafting == 'weapon';

      // 🔹 Equipamiento (armaduras, cascos, botas, capas)
      final isArmor = _armorNameRegex.hasMatch(id) ||
          (category == 'equipment' &&
              (subcat1 == 'armor' ||
                  subcat1 == 'head' ||
                  subcat1 == 'shoes' ||
                  subcat1 == 'cape')) ||
          id.contains('_ARMOR_') ||
          id.contains('_HEAD_') ||
          id.contains('_SHOES_') ||
          id.contains('_CAPE_');

      // 🔹 Consumibles
      final isConsumable = id.contains('FOOD_') || id.contains('POTION_');

      return isWeapon || isArmor || isConsumable;
    }).map((e) => Item.fromJson(e)).toList();

    items = items.take(1500).toList();

    print('✅ Ítems válidos filtrados (armas + equipamiento + consumibles): ${items.length}');
    return items;
  }
}
