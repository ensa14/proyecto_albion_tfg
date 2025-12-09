class Item {
  int realId;                 // Se asigna después (real ID de openalbion)
  final int index;
  final String id;            // UniqueName completo
  final String name;          // Nombre legible
  final String uniqueName;    // Alias del identificador
  final String iconUrl;

  final String type;          // weapon / armor / potion / food
  final List<String> activeSpells;
  final List<String> passiveSpells;

  final double attackDamage;
  final double attackSpeed;
  final double attackRange;
  final double itemPower;
  final double abilityPower;
  final double weight;
  final double durability;

  final String identifier;    // Lo mismo que uniqueName (siempre presente)

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

  // =====================================================
  // 🔥 NUEVO: DETECTAR EL TIER DESDE EL uniqueName
  // =====================================================
  String get tier {
    // Ejemplos:
    // T6_ARMOR_PLATE_SET3
    // T8_MAIN_FROSTSTAFF
    if (uniqueName.startsWith("T") && uniqueName.length >= 2) {
      return uniqueName.substring(0, 2); // "T6", "T8"
    }
    return "T?";
  }

  // Solo el número → 6, 8, 4...
  String get tierNumber {
    return tier.replaceAll("T", "");
  }

  // =====================================================
  // 🔥 FACTORY: CREACIÓN DESDE JSON
  // =====================================================
  factory Item.fromJson(Map<String, dynamic> json) {
    int realId = 0;
    int index = json["Index"] ?? json["index"] ?? 0;

    // UniqueName / Identificador principal
    final String id = json['UniqueName'] ??
        json['@uniquename'] ??
        json['uniquename'] ??
        json['Id'] ??
        json['id'] ??
        '';

    final String identifier = id;

    // Nombre visible
    String name = id;
    final localized = json['LocalizedNames'];
    if (localized is Map && localized.isNotEmpty) {
      name = localized.values.first.toString();
    }

    // Icono render
    final String iconUrl =
        'https://render.albiononline.com/v1/item/$id.png';

    // ==========================
    // 🔥 DETECCIÓN DEL TIPO REAL
    // ==========================
    String type = "unknown";
    final u = id.toUpperCase();

    if (u.contains("_MAIN_") || u.contains("_2H_") || u.contains("_OFF_")) {
      type = "weapon";
    } else if (u.contains("_HEAD_") ||
        u.contains("_ARMOR_") ||
        u.contains("_SHOES_") ||
        u.contains("_CAPE_")) {
      type = "armor";
    }

    if (u.contains("FOOD_")) type = "food";
    if (u.contains("POTION_")) type = "potion";

    // Extract spells
    List<String> extractSpells(dynamic slot) {
      if (slot == null || slot is! List) return [];
      return slot
          .map((e) => e["Spell"]?.toString() ?? "")
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final active = extractSpells(json["ActiveSpellSlots"]);
    final passive = extractSpells(json["PassiveSpellSlots"]);

    // Stats base
    double getStat(String key) {
      final raw = json[key]?.toString();
      return double.tryParse(raw ?? "0") ?? 0;
    }

    print("ITEM: $id | TYPE DETECTED = $type");

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
