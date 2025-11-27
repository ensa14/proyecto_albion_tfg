import 'package:flutter/material.dart';
import '../../asset/colores/colores.dart';
import '../../service/objetos_api_service.dart';
import '../../model/objetos_model.dart';
import '../../widget/header_albion.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late Future<List<Item>> _futureItems;
  final AlbionApiService _api = AlbionApiService();

  String _selectedTier = 'Todos';
  String _selectedCalidad = 'Todas';
  String _searchText = '';
  String? _selectedSlot;

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];

  // Equipamiento
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
    _futureItems = _api.fetchItems();
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final nameMatch =
            item.name.toLowerCase().contains(_searchText.toLowerCase());
        final tierMatch = _selectedTier == 'Todos' ||
            item.uniqueName.toUpperCase().startsWith(_selectedTier);
        final qualityMatch = _selectedCalidad == 'Todas' ||
            item.uniqueName.toLowerCase().contains(
                  _selectedCalidad.toLowerCase(),
                );

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
              slotMatch = id.contains('_main_') || id.contains('2h_');
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: SafeArea(
        child: Column(
          children: [
            HeaderAlbion(
              rightContent: isMobile
                  ? null
                  : Row(
                      children: [
                        _buildTierFilter(),
                        const SizedBox(width: 8),
                        _buildQualityFilter(),
                        const SizedBox(width: 8),
                        _buildSearch(),
                      ],
                    ),
            ),

            Expanded(
              child: FutureBuilder<List<Item>>(
                future: _futureItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    _allItems = snapshot.data!;
                    if (_filteredItems.isEmpty && _searchText.isEmpty) {
                      _filteredItems = _allItems;
                    }

                    return isMobile
                        ? _buildMobileLayout()
                        : _buildDesktopLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📱 MOBILE LAYOUT
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Filtros compactos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Panel de equipamiento (horizontal scroll)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

          // Grid de ítems
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return GestureDetector(
                  onTap: () => _equipItem(item),
                  child: Column(
                    children: [
                      Image.network(
                        item.iconUrl,
                        height: 60,
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
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 💻 DESKTOP LAYOUT
  // ============================================================

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Panel izquierdo
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

        // Panel derecho
        Expanded(
          flex: 6,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _filteredItems.length,
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

  // ============================================================
  // WIDGETS COMPARTIDOS
  // ============================================================

  Widget _buildSearch() {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar...',
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
      ),
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
          dropdownColor: AppColors.botonSecundario,
          items: tiers
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
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
          dropdownColor: AppColors.botonSecundario,
          items: calidades
              .map((q) => DropdownMenuItem(value: q, child: Text(q)))
              .toList(),
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
      children: slots
          .map(
            (slot) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => _selectSlot(slot),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _selectedSlot == slot
                            ? Colors.amber.withOpacity(0.3)
                            : Colors.white,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _equippedItems[slot] != null
                          ? Image.network(
                              _equippedItems[slot]!.iconUrl,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.help_outline,
                              size: 32, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(slot.toUpperCase(),
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
