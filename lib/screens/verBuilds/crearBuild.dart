import 'package:flutter/material.dart';
import '../../asset/colores/colores.dart';
import '../../service/objetos_api_service.dart';
import '../../model/objetos_model.dart';
import '../../widget/header_build.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late Future<List<Item>> _futureItems;
  final AlbionApiService _api = AlbionApiService(); // retorna List<Item>

  String _selectedTier = 'Todos';
  String _selectedCalidad = 'Todas';
  String _searchText = '';
  String? _selectedSlot;

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];

  final Map<String, Item?> _equippedItems = {
    'cape': null,
    'head': null,
    'armor': null,
    'shoes': null,
    'mainhand': null,
    'offhand': null,
  };

  @override
  void initState() {
    super.initState();
    _futureItems = _api.fetchItems(); // ahora devuelve List<Item>
  }

  // =====================================================
  //                 FILTROS
  // =====================================================
  void _applyFilters() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final nameMatch =
            item.name.toLowerCase().contains(_searchText.toLowerCase());

        final tierMatch = _selectedTier == 'Todos' ||
            item.uniqueName.toUpperCase().startsWith(_selectedTier);

        final qualityMatch = _selectedCalidad == 'Todas' ||
            item.uniqueName.toLowerCase().contains(_selectedCalidad.toLowerCase());

        bool slotMatch = true;

        if (_selectedSlot != null) {
          final id = item.uniqueName.toLowerCase();
          switch (_selectedSlot) {
            case 'head':
              slotMatch = id.contains('_head_');
              break;
            case 'armor':
              slotMatch = id.contains('_armor_');
              break;
            case 'shoes':
              slotMatch = id.contains('_shoes_');
              break;
            case 'cape':
              slotMatch = id.contains('_cape_');
              break;
            case 'mainhand':
              slotMatch = id.contains('_main_') || id.contains('2h');
              break;
            case 'offhand':
              slotMatch = id.contains('_off_');
              break;
          }
        }

        return nameMatch && tierMatch && qualityMatch && slotMatch;
      }).toList();
    });
  }

  void _selectSlot(String slot) {
    setState(() {
      _selectedSlot = slot;
      _applyFilters();
    });
  }

  void _equipItem(Item item) {
    if (_selectedSlot == null) return;

    setState(() {
      _equippedItems[_selectedSlot!] = item;
    });
  }

  // =====================================================
  //             BOTÓN SIGUIENTE
  // =====================================================
  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/agregarHabilidades',
            arguments: _equippedItems,
          );
        },
        child: const Text(
          "Siguiente",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =====================================================
  //                       BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: SafeArea(
        child: Column(
          children: [
            HeaderSimpleAlbion(
              rightContent: isMobile
                  ? null
                  : Row(
                      children: [
                        _buildTierFilter(),
                        const SizedBox(width: 8),
                        _buildQualityFilter(),
                        const SizedBox(width: 8),
                        SizedBox(width: 200, child: _buildSearch()),
                      ],
                    ),
            ),

            Expanded(
              child: FutureBuilder<List<Item>>(
                future: _futureItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  _allItems = snapshot.data!;

                  if (_filteredItems.isEmpty && _searchText.isEmpty) {
                    _filteredItems = List.from(_allItems);
                  }

                  return isMobile
                      ? _buildMobileLayout()
                      : _buildDesktopLayout();
                },
              ),
            ),

            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //                     MÓVIL
  // ======================================================
  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(child: _buildTierFilter()),
            const SizedBox(width: 8),
            Expanded(child: _buildQualityFilter()),
          ],
        ),

        const SizedBox(height: 10),

        _buildSearch(),

        const SizedBox(height: 20),

        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _equippedItems.keys.map((slot) {
              return GestureDetector(
                onTap: () => _selectSlot(slot),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _selectedSlot == slot
                        ? Colors.amber.withOpacity(0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _equippedItems[slot] != null
                          ? Image.network(
                              _equippedItems[slot]!.iconUrl,
                              height: 48,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.help_outline,
                              color: Colors.grey, size: 36),
                      const SizedBox(height: 4),
                      Text(slot.toUpperCase(),
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = _filteredItems[index];
            return GestureDetector(
              onTap: () => _equipItem(item),
              child: Column(
                children: [
                  Image.network(
                    item.iconUrl,
                    height: 56,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ======================================================
  //                     ESCRITORIO
  // ======================================================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEquipRow(['cape']),
                const SizedBox(height: 12),
                _buildEquipRow(['head', 'armor', 'shoes']),
                const SizedBox(height: 12),
                _buildEquipRow(['mainhand', 'offhand']),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 6,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return GestureDetector(
                onTap: () => _equipItem(item),
                child: Column(
                  children: [
                    Image.network(
                      item.iconUrl,
                      height: 64,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ======================================================
  //                  COMPONENTES COMUNES
  // ======================================================
  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Buscar...",
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      onChanged: (value) {
        _searchText = value;
        _applyFilters();
      },
    );
  }

  Widget _buildTierFilter() {
    final tiers = ['Todos', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.botonSecundario,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.headerBorde),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTier,
          items: tiers.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (value) {
            setState(() => _selectedTier = value!);
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildQualityFilter() {
    final calidades = [
      'Todas',
      'Normal',
      'Good',
      'Outstanding',
      'Excellent',
      'Masterpiece'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.botonSecundario,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.headerBorde),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCalidad,
          items: calidades.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
          onChanged: (value) {
            setState(() => _selectedCalidad = value!);
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildEquipRow(List<String> slots) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: slots.map((slot) {
        return GestureDetector(
          onTap: () => _selectSlot(slot),
          child: Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _selectedSlot == slot
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black54),
            ),
            child: _equippedItems[slot] != null
                ? Image.network(
                    _equippedItems[slot]!.iconUrl,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.help_outline,
                    size: 32, color: Colors.grey),
          ),
        );
      }).toList(),
    );
  }
}
