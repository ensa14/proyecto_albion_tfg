import 'package:flutter/material.dart';

class BuildDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const BuildDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final equipped = data["equipped"] ?? {};
    final skills = data["skills"] ?? {};
    final stats = data["statsTotales"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(data["nombre"] ?? "Build"),
        backgroundColor: Colors.amber,
      ),
      body: Row(
        children: [
          // ---------------------------------------------------
          // COLUMNA IZQUIERDA — ITEMS EQUIPADOS
          // ---------------------------------------------------
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _itemBox(equipped["cape"]),
                        const SizedBox(width: 12),
                        _itemBox(equipped["head"]),
                        const SizedBox(width: 12),
                        _itemBox(equipped["armor"]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _itemBox(equipped["mainhand"]),
                        const SizedBox(width: 12),
                        _itemBox(equipped["offhand"]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _itemBox(equipped["shoes"]),
                  ],
                ),
              ),
            ),
          ),

          // ---------------------------------------------------
          // COLUMNA DERECHA — STATS + HABILIDADES
          // ---------------------------------------------------
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estadísticas Totales",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    ...stats.entries.map(
                      (s) => Text("${s.key}: ${s.value}"),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Habilidades",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 12,
                      children: _mapSkillsToIcons(skills),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // Helper Items
  // ---------------------------------------------------
  Widget _itemBox(dynamic item) {
    if (item == null) {
      return Container(
        width: 95,
        height: 95,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: const Icon(Icons.close, size: 40, color: Colors.grey),
      );
    }

    return Container(
      width: 95,
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Image.network(
        item["icon"] ?? "",
        fit: BoxFit.cover,
      ),
    );
  }

  // ---------------------------------------------------
  // Helper Skills
  // ---------------------------------------------------
  List<Widget> _mapSkillsToIcons(Map skills) {
    final List<Widget> icons = [];

    for (var slot in skills.keys) {
      final group = skills[slot];
      if (group is Map) {
        for (var spell in group.values) {
          if (spell != null && spell["icon"] != null) {
            icons.add(
              ClipOval(
                child: Image.network(
                  spell["icon"],
                  width: 48,
                  height: 48,
                ),
              ),
            );
          }
        }
      }
    }

    return icons;
  }
}
