import 'package:flutter/material.dart';
import '../../model/objetos_model.dart';
import '../../model/spell_model.dart';
import '../../service/item_stasts_service.dart';

class BuildStastScreen extends StatefulWidget {
  final Map<String, Item?> equipped;
  final Map<String, Map<String, Spell?>> skills;

  const BuildStastScreen({
    super.key,
    required this.equipped,
    required this.skills,
  });

  @override
  State<BuildStastScreen> createState() => _BuildStastScreenState();
}

class _BuildStastScreenState extends State<BuildStastScreen> {
  final AlbionItemStatsService _statsAPI = AlbionItemStatsService();

  Map<String, double> totalStats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  // -----------------------------------------------------------
  //         CARGA STATS DE TODOS LOS ITEMS EQUIPADOS
  // -----------------------------------------------------------
  Future<void> _loadAllStats() async {
    Map<String, double> accumulator = {};

    for (var entry in widget.equipped.entries) {
      final slot = entry.key;
      final item = entry.value;

      if (item == null) continue;

      final type = _slotToType(slot);
      if (type == null) continue;

      final stats = await _statsAPI.getItemStats(item.realId, type);

      for (var s in stats) {
        final name = s["name"]!;
        final valueStr = s["value"]!.replaceAll(RegExp(r'[^0-9.]'), '');

        if (valueStr.isEmpty) continue;

        final value = double.tryParse(valueStr) ?? 0;

        accumulator[name] = (accumulator[name] ?? 0) + value;
      }
    }

    setState(() {
      totalStats = accumulator;
      loading = false;
    });
  }

  // Convierte slot → tipo API
  String? _slotToType(String slot) {
    if (slot == "mainhand") return "weapon";
    if (slot == "offhand") return "offhand";
    if (slot == "head") return "head";
    if (slot == "armor") return "armor";
    if (slot == "shoes") return "shoes";
    if (slot == "cape") return "cape";
    return null;
  }

  // -----------------------------------------------------------
  //                           UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resumen de la Build"),
        backgroundColor: Colors.amber,
      ),

      body: Row(
        children: [
          // ==================== EQUIPO ====================
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
                        _itemBox(widget.equipped["cape"]),
                        const SizedBox(width: 12),
                        _itemBox(widget.equipped["head"]),
                        const SizedBox(width: 12),
                        _itemBox(widget.equipped["armor"]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _itemBox(widget.equipped["mainhand"]),
                        const SizedBox(width: 12),
                        _itemBox(widget.equipped["offhand"]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _itemBox(widget.equipped["shoes"]),
                  ],
                ),
              ),
            ),
          ),

          // ==================== STATS + HABILIDADES ====================
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Estadísticas Totales",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  if (loading)
                    const CircularProgressIndicator()
                  else
                    ...totalStats.entries.map(
                      (stat) => _statText(stat.key, stat.value.toString()),
                    ),

                  const SizedBox(height: 25),

                  const Text(
                    "Habilidades Seleccionadas",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: _abilityIcons(),
                  ),

                  const Spacer(),

                  // ---------- GUARDAR BUILD ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Guardar build...");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Guardar Build",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---------- VOLVER ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "← Volver",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // Widgets reutilizables
  // -----------------------------------------------------------
  Widget _itemBox(Item? item) {
    return Container(
      width: 95,
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: item != null
          ? Image.network(item.iconUrl, fit: BoxFit.cover)
          : const Icon(Icons.close, size: 40, color: Colors.grey),
    );
  }

  Widget _statText(String stat, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$stat: $value",
          style: const TextStyle(fontSize: 16, height: 1.3)),
    );
  }

  List<Widget> _abilityIcons() {
    List<Spell?> all = [];

    for (var slot in widget.skills.keys) {
      all.add(widget.skills[slot]!["q"]);
      all.add(widget.skills[slot]!["w"]);
      all.add(widget.skills[slot]!["e"]);
      all.add(widget.skills[slot]!["active"]);
      all.add(widget.skills[slot]!["passive"]);
    }

    return all.where((s) => s != null).map(
      (s) {
        return ClipOval(
            child: Image.network(s!.icon, height: 48, width: 48));
      },
    ).toList();
  }
}
