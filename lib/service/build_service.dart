import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/build_model.dart';

class BuildService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener todas las builds de un usuario
  Future<List<BuildModel>> getBuildsByUser(String userId) async {
    final query = await _db
        .collection('builds')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) => BuildModel.fromDocument(doc))
        .toList();
  }

  /// Obtener UNA build por ID
  Future<BuildModel?> getBuildById(String buildId) async {
    final doc = await _db.collection('builds').doc(buildId).get();
    if (!doc.exists) return null;
    return BuildModel.fromDocument(doc);
  }

  /// Crear una nueva build en Firestore
  Future<String> createBuild(BuildModel build) async {
    final docRef = _db.collection('builds').doc();

    await docRef.set(build.toMap());

    return docRef.id; // Devuelve el ID generado
  }

  /// Actualizar una build existente
  Future<void> updateBuild(BuildModel build) async {
    await _db.collection('builds').doc(build.id).update({
      ...build.toMap(),
      'updatedAt': Timestamp.now(), // actualiza la fecha automáticamente
    });
  }

  /// Eliminar una build por ID
  Future<void> deleteBuild(String buildId) async {
    await _db.collection('builds').doc(buildId).delete();
  }
}
