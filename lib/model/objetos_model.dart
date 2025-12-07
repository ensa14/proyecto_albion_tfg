class Item {
  int realId;                 // realId se asignará después
  final int index;
  final String id;
  final String name;
  final String uniqueName;
  final String iconUrl;

  final String type;

  final List<String> activeSpells;
  final List<String> passiveSpells;

  final double attackDamage;
  final double attackSpeed;
  final double attackRange;
  final double itemPower;
  final double abilityPower;
  final double weight;
  final double durability;

  final String identifier;    // AHORA SIEMPRE EXISTE

  Item({
    required this.realId,
    required this.index,
    required this.id,
    required this.name,
    required this.uniqueName,
    required this.iconUrl,
    required this.type,
    required this.activeSpells,
    required this.passiveSpells,
    required this.attackDamage,
    required this.attackSpeed,
    required this.attackRange,
    required this.itemPower,
    required this.abilityPower,
    required this.weight,
    required this.durability,
    required this.identifier,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // El dump NO trae realId → siempre 0 al inicio
    int realId = 0;

    int index = json["Index"] ?? json["index"] ?? 0;

    // UniqueName = el nombre REAL usado en la API nueva
    final String id = json['UniqueName'] ??
        json['@uniquename'] ??
        json['uniquename'] ??
        json['Id'] ??
        json['id'] ??
        '';

    // El identifier SIEMPRE será el UniqueName
    final String identifier = id;

    // Nombre visible
    String name = id;
    final localized = json['LocalizedNames'];
    if (localized is Map && localized.isNotEmpty) {
      name = localized.values.first.toString();
    }

    final String iconUrl =
        'https://render.albiononline.com/v1/item/$id.png';

    final shopCat =
        (json['ShopCategory'] ?? json['shopcategory'] ?? '')
            .toString()
            .toLowerCase();

    final shopSub =
        (json['ShopSubCategory1'] ?? json['shopsubcategory1'] ?? '')
            .toString()
            .toLowerCase();

    String type = "unknown";

    if (shopCat == 'equipment') {
      if (shopSub.contains('mainhand') ||
          shopSub.contains('2h') ||
          shopSub.contains('offhand')) {
        type = "weapon";
      } else {
        type = "armor";
      }
    }

    if (id.contains("FOOD_")) type = "food";
    if (id.contains("POTION_")) type = "potion";

    List<String> extractSpells(dynamic slot) {
      if (slot == null || slot is! List) return [];
      return slot
          .map((e) => e["Spell"]?.toString() ?? "")
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final active = extractSpells(json["ActiveSpellSlots"]);
    final passive = extractSpells(json["PassiveSpellSlots"]);

    double getStat(String key) {
      final raw = json[key]?.toString();
      return double.tryParse(raw ?? "0") ?? 0;
    }

    // LOG ÚTIL
    print("ITEM: $id | identifier asignado = $identifier");

    return Item(
      realId: realId,
      index: index,
      id: id,
      name: name,
      uniqueName: id,
      identifier: identifier,
      iconUrl: iconUrl,
      type: type,
      activeSpells: active,
      passiveSpells: passive,
      attackDamage: getStat('@attackdamage'),
      attackSpeed: getStat('@attackspeed'),
      attackRange: getStat('@attackrange'),
      itemPower: getStat('@itempower'),
      abilityPower: getStat('@abilitypower'),
      weight: getStat('@weight'),
      durability: getStat('@durability'),
    );
  }
}
