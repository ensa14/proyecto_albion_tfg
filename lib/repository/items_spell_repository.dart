import '../service/objetos_api_service.dart';
import '../service/spell_service.dart';
import '../model/objetos_model.dart';
import '../model/spell_model.dart';

/// Paquete completo de info de un ítem:
/// - el Item (stats, icono, tier, etc.)
/// - todas sus spells
/// - spells ya separadas por Q / W / E / Pasivas
class ItemWithSpells {
  final Item item;
  final List<Spell> allSpells;

  final List<Spell> qSpells;
  final List<Spell> wSpells;
  final List<Spell> eSpells;
  final List<Spell> passiveSpells;

  ItemWithSpells({
    required this.item,
    required this.allSpells,
    required this.qSpells,
    required this.wSpells,
    required this.eSpells,
    required this.passiveSpells,
  });
}

class AlbionRepository {
  final AlbionApiService _itemsApi;
  final SpellsApiService _spellsApi;

  AlbionRepository({
    AlbionApiService? itemsApi,
    SpellsApiService? spellsApi,
  })  : _itemsApi = itemsApi ?? AlbionApiService(),
        _spellsApi = spellsApi ?? SpellsApiService();

  /// ----------------------------------------------------
  /// 1) Cargar TODOS los ítems desde tu sistema local
  /// ----------------------------------------------------
  Future<List<Item>> fetchAllItems() async {
    final items = await _itemsApi.fetchItems();
    return items;
  }

  /// ----------------------------------------------------
  /// 2) Cargar spells del ítem desde OpenAlbion
  /// ----------------------------------------------------
  Future<ItemWithSpells> getItemWithSpells(Item item) async {
    print("🔵 Cargando spells del item '${item.name}' con realId = ${item.realId}");

    if (item.realId == 0) {
      print("❌ ERROR: realId = 0 → sin spells");
      return ItemWithSpells(
        item: item,
        allSpells: [],
        qSpells: [],
        wSpells: [],
        eSpells: [],
        passiveSpells: [],
      );
    }

    final all = await _spellsApi.loadSpellsByRealId(item.realId);

    // Separar por slots de OpenAlbion:
    final q = all.where((s) => s.slot == "First Slot").toList();
    final w = all.where((s) => s.slot == "Second Slot").toList();
    final e = all.where((s) => s.slot == "Third Slot").toList();
    final passive = all.where((s) => s.slot == "Passive").toList();

    return ItemWithSpells(
      item: item,
      allSpells: all,
      qSpells: q,
      wSpells: w,
      eSpells: e,
      passiveSpells: passive,
    );
  }
}
