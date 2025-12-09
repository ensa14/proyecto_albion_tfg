import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../asset/colores/colores.dart';
import '../../widget/header_albion.dart';
import '../../provider/auth_provider.dart';
import '../../screens/verBuilds/BuildDetailScreen.dart';

class BuildsScreen extends StatefulWidget {
  const BuildsScreen({super.key});

  @override
  State<BuildsScreen> createState() => _BuildsScreenState();
}

class _BuildsScreenState extends State<BuildsScreen> {
  String searchText = "";
  String? selectedWeaponType;

  // Tipos de armas
  final List<String> weaponTypes = [
    "bow",
    "crossbow",
    "sword",
    "axe",
    "hammer",
    "mace",
    "dagger",
    "spear",
    "firestaff",
    "holystaff",
    "cursestaff",
    "arcane staff",
    "quarterstaff",
    "naturestaff",
    "war glove",
  ];

  // Limpia Map<dynamic, dynamic>
  Map<String, dynamic> safeMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    return {};
  }

  // Detecta tipo de arma según idObjeto
  String getWeaponTypeFromId(String id) {
    id = id.toLowerCase();

    if (id.contains("bow") && !id.contains("crossbow")) return "bow";
    if (id.contains("crossbow")) return "crossbow";
    if (id.contains("sword")) return "sword";
    if (id.contains("axe")) return "axe";
    if (id.contains("hammer")) return "hammer";
    if (id.contains("mace")) return "mace";
    if (id.contains("dagger")) return "dagger";
    if (id.contains("spear")) return "spear";
    if (id.contains("firestaff")) return "firestaff";
    if (id.contains("holystaff")) return "holystaff";
    if (id.contains("cursestaff")) return "cursestaff";
    if (id.contains("arcanestaff")) return "arcane staff";
    if (id.contains("quarterstaff")) return "quarterstaff";
    if (id.contains("naturestaff")) return "naturestaff";
    if (id.contains("glove")) return "war glove";

    return "other";
  }

  IconData getWeaponIcon(String type) {
    switch (type) {
      case "bow":
        return Icons.architecture;
      case "crossbow":
        return Icons.add_chart;
      case "sword":
        return Icons.gavel;
      case "axe":
        return Icons.construction;
      case "hammer":
        return Icons.construction_outlined;
      case "mace":
        return Icons.shield;
      case "dagger":
        return Icons.call_split;
      case "spear":
        return Icons.trending_up;
      case "firestaff":
        return Icons.local_fire_department;
      case "holystaff":
        return Icons.auto_awesome;
      case "cursestaff":
        return Icons.sick;
      case "arcane staff":
        return Icons.auto_fix_high;
      case "quarterstaff":
        return Icons.sports_martial_arts;
      case "naturestaff":
        return Icons.eco;
      case "war glove":
        return Icons.back_hand;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              HeaderAlbion(
                rightContent: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        onChanged: (value) {
                          setState(() => searchText = value.toLowerCase());
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar build...',
                          isDense: true,
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: AppColors.iconoInput,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // DROPDOWN TIPO DE ARMA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: selectedWeaponType,
                  hint: const Text("Filtrar por arma"),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text("Todas las armas"),
                    ),
                    ...weaponTypes.map((type) {
                      return DropdownMenuItem<String?>(
                        value: type,
                        child: Row(
                          children: [
                            Icon(getWeaponIcon(type), size: 18),
                            const SizedBox(width: 10),
                            Text(type.toUpperCase()),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => selectedWeaponType = value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // LISTA DE BUILDS DEL USUARIO (ORDENADO MANUAL)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("builds")
                    .where("userToken", isEqualTo: auth.token)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final docs = snapshot.data!.docs;

                  // ORDENAR MANUALMENTE POR FECHA (EVITA BUG DE WINDOWS)
                  docs.sort((a, b) {
                    final t1 =
                        (a["createdAt"] as Timestamp?)?.toDate() ?? DateTime(0);
                    final t2 =
                        (b["createdAt"] as Timestamp?)?.toDate() ?? DateTime(0);
                    return t2.compareTo(t1);
                  });

                  // APLICAR FILTROS LOCALES
                  final filtradas = docs.where((doc) {
                    final data = safeMap(doc.data());
                    final nombre =
                        (data["nombre"] ?? "").toString().toLowerCase();
                    final descripcion =
                        (data["descripcion"] ?? "").toString().toLowerCase();

                    // filtro por texto
                    if (!nombre.contains(searchText) &&
                        !descripcion.contains(searchText)) {
                      return false;
                    }

                    // filtro por arma
                    if (selectedWeaponType != null) {
                      final equipped = safeMap(data["equipped"]);
                      final mainhand = safeMap(equipped["mainhand"]);
                      final idObjeto = (mainhand["idObjeto"] ?? "").toString();

                      final tipo = getWeaponTypeFromId(idObjeto);
                      if (tipo != selectedWeaponType) return false;
                    }

                    return true;
                  }).toList();

                  if (filtradas.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: Text("No hay builds que coincidan.")),
                    );
                  }

                  return Column(
                    children:
                        filtradas.map((doc) => _buildCard(context, doc)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CARD DE UNA BUILD
  Widget _buildCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = safeMap(doc.data());
    final equipped = safeMap(data["equipped"]);
    final mainhand = safeMap(equipped["mainhand"]);

    final icon =
        mainhand["icon"] ?? "https://placehold.co/90x90?text=No+Item";

    final nombre = data["nombre"] ?? "Build sin nombre";
    final descripcion = data["descripcion"] ?? "Sin descripción";

    

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                icon,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headerTexto,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                      final data = safeMap(doc.data());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuildDetailScreen(data: data),
                        ),
                      );
                    },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blanco,
                        ),
                        child: const Text("Ver"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("builds")
                              .doc(doc.id)
                              .delete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
