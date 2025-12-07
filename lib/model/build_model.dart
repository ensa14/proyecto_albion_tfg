import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para un ítem dentro de la lista opcional `items`
class ItemBuild {
  final String nombre;
  final String tier;
  final String imagen;

  ItemBuild({
    required this.nombre,
    required this.tier,
    required this.imagen,
  });

  factory ItemBuild.fromMap(Map<String, dynamic> map) {
    return ItemBuild(
      nombre: map['nombre'] ?? '',
      tier: map['tier'] ?? '',
      imagen: map['imagen'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tier': tier,
      'imagen': imagen,
    };
  }
}

/// Modelo principal de la build
class BuildModel {
  final String id;
  final String userId;
  final String nombre;
  final String clase;
  final String descripcion;

  // EQUIPAMIENTO
  final String arma;
  final String armaSecundaria;
  final String armadura;
  final String casco;
  final String botas;
  final String capa;
  final String comida;   // nuevo
  final String pocion;   // nuevo

  // HABILIDADES ARMA PRINCIPAL
  final String armaQ;
  final String armaW;
  final String armaE;
  final String armaPasiva;

  // HABILIDADES ARMA SECUNDARIA
  final String armaSecQ;
  final String armaSecW;
  final String armaSecE;
  final String armaSecPasiva;

  // HABILIDADES ARMADURA / CASCO / BOTAS / CAPA
  final String cascoSpell;
  final String armaduraSpell;
  final String botasSpell;
  final String capaPasiva;

  final List<ItemBuild> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  BuildModel({
    required this.id,
    required this.userId,
    required this.nombre,
    required this.clase,
    required this.descripcion,
    required this.arma,
    required this.armaSecundaria,
    required this.armadura,
    required this.casco,
    required this.botas,
    required this.capa,
    required this.comida,
    required this.pocion,
    required this.armaQ,
    required this.armaW,
    required this.armaE,
    required this.armaPasiva,
    required this.armaSecQ,
    required this.armaSecW,
    required this.armaSecE,
    required this.armaSecPasiva,
    required this.cascoSpell,
    required this.armaduraSpell,
    required this.botasSpell,
    required this.capaPasiva,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Conversión desde Firestore
  factory BuildModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<ItemBuild> parsedItems =
        (data['items'] as List<dynamic>? ?? [])
            .map((e) => ItemBuild.fromMap(e))
            .toList();

    return BuildModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      nombre: data['nombre'] ?? '',
      clase: data['clase'] ?? '',
      descripcion: data['descripcion'] ?? '',

      arma: data['arma'] ?? '',
      armaSecundaria: data['armaSecundaria'] ?? '',
      armadura: data['armadura'] ?? '',
      casco: data['casco'] ?? '',
      botas: data['botas'] ?? '',
      capa: data['capa'] ?? '',
      comida: data['comida'] ?? '',
      pocion: data['pocion'] ?? '',

      // habilidades arma principal
      armaQ: data['armaQ'] ?? '',
      armaW: data['armaW'] ?? '',
      armaE: data['armaE'] ?? '',
      armaPasiva: data['armaPasiva'] ?? '',

      // habilidades arma secundaria
      armaSecQ: data['armaSecQ'] ?? '',
      armaSecW: data['armaSecW'] ?? '',
      armaSecE: data['armaSecE'] ?? '',
      armaSecPasiva: data['armaSecPasiva'] ?? '',

      // habilidades de equipo
      cascoSpell: data['cascoSpell'] ?? '',
      armaduraSpell: data['armaduraSpell'] ?? '',
      botasSpell: data['botasSpell'] ?? '',
      capaPasiva: data['capaPasiva'] ?? '',

      items: parsedItems,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Conversión a mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nombre': nombre,
      'clase': clase,
      'descripcion': descripcion,

      'arma': arma,
      'armaSecundaria': armaSecundaria,
      'armadura': armadura,
      'casco': casco,
      'botas': botas,
      'capa': capa,
      'comida': comida,
      'pocion': pocion,

      // habilidades arma principal
      'armaQ': armaQ,
      'armaW': armaW,
      'armaE': armaE,
      'armaPasiva': armaPasiva,

      // habilidades arma secundaria
      'armaSecQ': armaSecQ,
      'armaSecW': armaSecW,
      'armaSecE': armaSecE,
      'armaSecPasiva': armaSecPasiva,

      // habilidades equipo
      'cascoSpell': cascoSpell,
      'armaduraSpell': armaduraSpell,
      'botasSpell': botasSpell,
      'capaPasiva': capaPasiva,

      'items': items.map((e) => e.toMap()).toList(),

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
