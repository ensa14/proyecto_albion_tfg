class Spell {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String slot; // First Slot / Second Slot / Third Slot / Passive
  final double cooldown;
  final double energyCost;

  Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.slot,
    required this.cooldown,
    required this.energyCost,
  });

  factory Spell.fromJson(Map<String, dynamic> json) {
    double parseValue(String attrName) {
      final attrs = json["attributes"] as List?;
      if (attrs == null) return 0;

      final found = attrs.firstWhere(
        (a) => a["name"] == attrName,
        orElse: () => null,
      );

      if (found == null) return 0;

      final raw = found["value"]?.toString() ?? "";

      // limpiar cualquier cosa que NO sea número o punto
      final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');

      if (cleaned.isEmpty) return 0;

      return double.tryParse(cleaned) ?? 0;
    }

    return Spell(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      icon: json["icon"] ?? "",
      slot: json["slot"] ?? "",

      // atributos reales de la API nueva
      cooldown: parseValue("Cooldown"),
      energyCost: parseValue("Energy Cost"),
    );
  }
}
