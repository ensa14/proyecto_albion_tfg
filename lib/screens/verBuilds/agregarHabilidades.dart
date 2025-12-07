import 'package:flutter/material.dart';
import '../../model/objetos_model.dart';
import '../../service/spell_service.dart';
import '../../model/spell_model.dart';

class AgregarHabilidadesScreen extends StatefulWidget {
  const AgregarHabilidadesScreen({super.key});

  @override
  State<AgregarHabilidadesScreen> createState() =>
      _AgregarHabilidadesScreenState();
}

class _AgregarHabilidadesScreenState extends State<AgregarHabilidadesScreen> {
  final SpellsApiService _api = SpellsApiService();

  late Map<String, Item?> equippedItems;

  Map<String, bool> expanded = {};
  Map<String, bool> loading = {};
  Map<String, List<Spell>> loadedSpells = {};

  Map<String, Map<String, Spell?>> selectedSpells = {};

  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      equippedItems =
          ModalRoute.of(context)!.settings.arguments as Map<String, Item?>;

      for (var slot in equippedItems.keys) {
        expanded[slot] = false;
        loading[slot] = false;
        loadedSpells[slot] = [];

        selectedSpells[slot] = {
          "q": null,
          "w": null,
          "e": null,
          "passive": null,
        };
      }

      initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar habilidades"),
        backgroundColor: Colors.amber,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: equippedItems.entries.map((entry) {
          final slot = entry.key;
          final item = entry.value;

          return Column(
            children: [
              _buildSlotHeader(slot, item),
              if (expanded[slot] == true && item != null)
                _buildSpellContent(slot),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            Navigator.pop(context, selectedSpells);
          },
          child: const Text(
            "Continuar",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // ENCABEZADO DEL SLOT
  // -------------------------------------------------
  Widget _buildSlotHeader(String slot, Item? item) {
    return Card(
      child: ListTile(
        leading: item != null
            ? Image.network(item.iconUrl, height: 40, width: 40)
            : const Icon(Icons.help_outline, size: 32),
        title: Text(slot.toUpperCase()),
        subtitle: Text(item?.name ?? "Vacío"),
        trailing: Icon(
          expanded[slot] == true
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
        ),
        onTap: () async {
          if (item == null) return;

          setState(() => expanded[slot] = !expanded[slot]!);

          if (expanded[slot] == true && loadedSpells[slot]!.isEmpty) {
            await _loadItemSpells(slot);
          }
        },
      ),
    );
  }

  // -------------------------------------------------
  // CARGAR SPELLS POR REAL ID
  // -------------------------------------------------
  Future<void> _loadItemSpells(String slot) async {
    final item = equippedItems[slot];

    if (item == null) {
      loadedSpells[slot] = [];
      return;
    }

    if (item.realId == 0) {
      print("❌ realId es 0 para ${item.name}");
      setState(() => loadedSpells[slot] = []);
      return;
    }

    setState(() => loading[slot] = true);

    final spells = await _api.loadSpellsByRealId(item.realId);

    setState(() {
      loadedSpells[slot] = spells;
      loading[slot] = false;
    });
  }

  // -------------------------------------------------
  // CONTENIDO EXPANDIDO DE SPELLS
  // -------------------------------------------------
  Widget _buildSpellContent(String slot) {
    final spells = loadedSpells[slot] ?? [];

    if (loading[slot] == true) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }

    if (spells.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No hay habilidades disponibles."),
      );
    }

    // Slots según la API nueva
    final q = spells.where((s) => s.slot == "First Slot").toList();
    final w = spells.where((s) => s.slot == "Second Slot").toList();
    final e = spells.where((s) => s.slot == "Third Slot").toList();
    final passive = spells.where((s) => s.slot == "Passive").toList();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (q.isNotEmpty)
            _spellDropdown(slot: slot, title: "Q", keyName: "q", items: q),

          if (w.isNotEmpty)
            _spellDropdown(slot: slot, title: "W", keyName: "w", items: w),

          if (e.isNotEmpty)
            _spellDropdown(slot: slot, title: "E", keyName: "e", items: e),

          if (passive.isNotEmpty)
            _spellDropdown(
                slot: slot, title: "Pasiva", keyName: "passive", items: passive),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // DROPDOWN DE SPELLS
  // -------------------------------------------------
  Widget _spellDropdown({
    required String slot,
    required String title,
    required String keyName,
    required List<Spell> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),

        DropdownButton<Spell>(
          isExpanded: true,
          value: selectedSpells[slot]![keyName],
          hint: const Text("Seleccionar habilidad"),
          items: items.map((spell) {
            return DropdownMenuItem(
              value: spell,
              child: Row(
                children: [
                  Image.network(spell.icon, height: 32, width: 32),
                  const SizedBox(width: 8),
                  Expanded(child: Text(spell.name)),
                ],
              ),
            );
          }).toList(),
          onChanged: (Spell? val) {
            setState(() {
              selectedSpells[slot]![keyName] = val;
            });
          },
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
