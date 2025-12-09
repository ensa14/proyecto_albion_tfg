import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/objetos_model.dart';
import '../model/spell_model.dart';

class BuildFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================================================
  //  GUARDAR UNA BUILD COMPLETA EN FIRESTORE
  // ===============================================================
  Future<String> saveBuild({
    required String userToken,
    required String nombre,
    required String descripcion,
    required Map<String, Item?> equipped,
    required Map<String, Map<String, Spell?>> skills,
    required Map<String, double> totalStats,
    required String clase,
  }) async {
    try {
      // -----------------------------------------------------------
      // EQUIPPED → convertir items
      // -----------------------------------------------------------
      final equippedMap = equipped.map((slot, item) {
        if (item == null) return MapEntry(slot, null);

        return MapEntry(slot, {
          "name": item.name,
          "tier": item.tier,
          "icon": item.iconUrl,
          "idObjeto": item.id,
        });
      });

      // -----------------------------------------------------------
      // SKILLS → convertir spells
      // -----------------------------------------------------------
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

      // -----------------------------------------------------------
      // GUARDAR BUILD EN FIRESTORE
      // -----------------------------------------------------------
      final docRef = await _db.collection("builds").add({
        "userToken": userToken,
        "nombre": nombre,
        "descripcion": descripcion,
        "clase": clase,
        "equipped": equippedMap,
        "skills": skillsMap,
        "statsTotales": totalStats,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      print("🔥 Build guardada con ID: ${docRef.id}");
      return docRef.id;

    } catch (e) {
      print("❌ ERROR al guardar la build en Firestore → $e");
      rethrow;
    }
  }
}
