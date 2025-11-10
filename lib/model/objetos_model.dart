class Item {
  final String id;
  final String name;
  final String uniqueName;
  final String iconUrl;

  Item({
    required this.id,
    required this.name,
    required this.uniqueName,
    required this.iconUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final String id = json['UniqueName'] ??
        json['@uniquename'] ??
        json['uniquename'] ??
        json['Id'] ??
        json['id'] ??
        '';

    final Map<String, dynamic>? names = json['LocalizedNames'];

    final String name = names != null && names.isNotEmpty
        ? names.values.first
        : id.isNotEmpty
            ? id
            : 'Sin nombre';

    return Item(
      id: id,
      name: name,
      uniqueName: id,
      iconUrl: 'https://render.albiononline.com/v1/item/$id.png',
    );
  }
}
