import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para un ítem dentro de una build (arma, armadura, etc.)
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

/// Modelo principal de la build (documento de la colección `builds`)
class BuildModel {
  final String id;              // ID del documento en Firestore
  final String userId;
  final String nombre;          // nombre de la build
  final String clase;           // Healer, Tank, etc.
  final String descripcion;

  final String arma;
  final String armaSecundaria;
  final String armadura;
  final String casco;
  final String botas;
  final String capa;

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
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear desde un DocumentSnapshot de Firestore
  factory BuildModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // items es un array de maps
    final List<dynamic> rawItems = data['items'] ?? [];
    final List<ItemBuild> parsedItems = rawItems
        .map((e) => ItemBuild.fromMap(e as Map<String, dynamic>))
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
      items: parsedItems,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Pasar a mapa para guardar/actualizar en Firestore
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
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
