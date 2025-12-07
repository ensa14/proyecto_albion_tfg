import 'package:flutter/material.dart';
import '../../model/objetos_model.dart';
import '../../model/spell_model.dart';

class BuildStastScreen extends StatelessWidget {
  final Map<String, Item?> equipped;   // cape, head, armor, shoes, mainhand, offhand
  final Map<String, Map<String, Spell?>> skills; // q/w/e/active/passive por cada slot

  const BuildStastScreen({
    super.key,
    required this.equipped,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resumen de la Build"),
        backgroundColor: Colors.amber,
      ),

      body: Row(
        children: [
          // -----------------------------------------------
          //           COLUMNA IZQUIERDA — EQUIPO
          // -----------------------------------------------

          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PRIMERA FILA
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

                    // SEGUNDA FILA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _itemBox(equipped["mainhand"]),
                        const SizedBox(width: 12),
                        _itemBox(equipped["offhand"]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // TERCERA FILA (solo zapatos)
                    _itemBox(equipped["shoes"]),
                  ],
                ),
              ),
            ),
          ),

          // -----------------------------------------------
          //        COLUMNA DERECHA — STATS + HABILIDADES
          // -----------------------------------------------

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Estadísticas",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _statText("Vida Máxima", "+2000 HP"),
                  _statText("Resistencia Física", "+350"),
                  _statText("Resistencia Mágica", "+300"),
                  _statText("Energía", "+50"),
                  _statText("Velocidad movimiento", "-5%"),
                  _statText("CC Resist", "+15%"),
                  _statText("Daño habilidades", "+8%"),
                  _statText("Curación", "+8%"),
                  _statText("Daño autoataques", "+5%"),

                  const SizedBox(height: 25),

                  const Text("Habilidades Seleccionadas",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    children: _abilityIcons(),
                  ),

                  const Spacer(),

                  // -----------------------
                  //   GUARDAR BUILD
                  // -----------------------
                  ElevatedButton(
                    onPressed: () {
                      // Guardar en API, Firebase o local
                      print("Guardar build...");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Center(
                      child: Text(
                        "Guardar Build",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // -----------------------
                  //        VOLVER
                  // -----------------------
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Center(
                      child: Text(
                        "← Volver",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
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

  // --------------------------------------------------
  //  CAJA PARA MOSTRAR UN ITEM EQUIPADO
  // --------------------------------------------------
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

  // --------------------------------------------------
  //  TEXTO DE UN STAT
  // --------------------------------------------------
  Widget _statText(String stat, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$stat: $value",
          style: const TextStyle(fontSize: 16, height: 1.3)),
    );
  }

  // --------------------------------------------------
  //  ICONOS DE HABILIDADES ELEGIDAS
  // --------------------------------------------------
  List<Widget> _abilityIcons() {
    List<Spell?> all = [];

    for (var slot in skills.keys) {
      all.add(skills[slot]!["q"]);
      all.add(skills[slot]!["w"]);
      all.add(skills[slot]!["e"]);
      all.add(skills[slot]!["active"]);
      all.add(skills[slot]!["passive"]);
    }

    return all
        .where((s) => s != null)
        .map((s) => ClipOval(
              child: Image.network(s!.icon, height: 48, width: 48),
            ))
        .toList();
  }
}
