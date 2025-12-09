import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/objetos_model.dart';
import '../model/spell_model.dart';

class BuildService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //-------------------------------------------------------------------
  //  GUARDAR UNA BUILD COMPLETA EN FIRESTORE
  //-------------------------------------------------------------------
  Future<void> saveBuild({
    required String userToken, 
    required String nombre,
    required String descripcion,
    required Map<String, Item?> equipped,
    required Map<String, Map<String, Spell?>> skills,
    required Map<String, double> totalStats,
    required String clase,
  }) async {
    
    // EQUIPPED → convertir items
    final equippedMap = equipped.map((slot, item) {
      if (item == null) return MapEntry(slot, null);

      return MapEntry(slot, {
        "name": item.name,
        "tier": item.tier,
        "icon": item.iconUrl,
        "idObjeto": item.id,
      });
    });

    // SKILLS → convertir spells
    final skillsMap = skills.map((slot, group) {
      final converted = group.map((key, spell) {
        if (spell == null) return MapEntry(key, null);

        return MapEntry(key, {
          "name": spell.name,
          "icon": spell.icon,
        });
      });

      return MapEntry(slot, converted);
    });

    // GUARDAR EN FIRESTORE
    await _db.collection("builds").add({
      "userToken": userToken,               // 🔥 Identificador único
      "nombre": nombre,
      "descripcion": descripcion,
      "clase": clase,
      "equipped": equippedMap,
      "skills": skillsMap,
      "statsTotales": totalStats,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  //-------------------------------------------------------------------
  //  OBTENER TODAS LAS BUILDS DEL USUARIO
  //-------------------------------------------------------------------
  Stream<QuerySnapshot> getUserBuilds(String userToken) {
    return _db
        .collection("builds")
        .where("userToken", isEqualTo: userToken)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  //-------------------------------------------------------------------
  //  ELIMINAR
  //-------------------------------------------------------------------
  Future<void> deleteBuild(String id) async {
    await _db.collection("builds").doc(id).delete();
  }
}
