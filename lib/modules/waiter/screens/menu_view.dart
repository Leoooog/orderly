import 'package:flutter/material.dart';
import 'package:orderly/shared/widgets/quantity_button.dart';

import '../../../config/themes.dart';
import '../../../data/mock_data.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/course.dart';
import '../../../data/models/extra.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/table_item.dart';

class MenuView extends StatefulWidget {
  final TableItem table;
  final VoidCallback onBack;
  final Function(List<CartItem>) onSuccess;

  const MenuView(
      {super.key,
      required this.table,
      required this.onBack,
      required this.onSuccess});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView>
    with SingleTickerProviderStateMixin {
  String activeCategory = 'fav';
  Course activeCourse = Course.entree;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  List<CartItem> cart = []; // Solo nuovi ordini
  final TextEditingController noteController = TextEditingController();

  late AnimationController _controller;
  final double _minHeight = 85.0;
  double _maxHeight = 0.0;
  bool _isExpanded = false;

  final Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    // IL CARRELLO PARTE VUOTO (Separazione Nuovo/Storico)
    cart = [];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    noteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // --- LOGICA GESTIONE CARRELLO ---

  void _addToCart(MenuItem item) {
    setState(() {
      final existingIndex = cart.indexWhere((c) =>
          c.id == item.id &&
          c.notes.isEmpty &&
          c.course == activeCourse &&
          c.selectedExtras.isEmpty);

      if (existingIndex >= 0) {
        cart[existingIndex].qty++;
      } else {
        cart.add(CartItem(
          internalId: DateTime.now().millisecondsSinceEpoch,
          id: item.id,
          name: item.name,
          basePrice: item.price,
          course: activeCourse,
        ));
      }
    });
  }

  void _updateQty(CartItem item, int delta) {
    setState(() {
      item.qty += delta;
      if (item.qty <= 0) {
        cart.remove(item);
        if (cart.isEmpty && _isExpanded) {
          _controller.animateTo(0, curve: Curves.easeOutQuint);
          _isExpanded = false;
        }
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      cart.remove(item);
      if (cart.isEmpty && _isExpanded) {
        _controller.animateTo(0, curve: Curves.easeOutQuint);
        _isExpanded = false;
      }
    });
  }

  bool _areExtrasEqual(List<Extra> a, List<Extra> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds);
  }

  void _saveItemChanges(
      CartItem item, String newNote, Course newCourse, List<Extra> newExtras) {
    setState(() {
      if (item.notes == newNote &&
          item.course == newCourse &&
          _areExtrasEqual(item.selectedExtras, newExtras)) return;

      if (item.qty > 1) {
        item.qty--;
        final existingMatch = cart.indexWhere((c) =>
            c.id == item.id &&
            c.notes == newNote &&
            c.course == newCourse &&
            _areExtrasEqual(c.selectedExtras, newExtras));

        if (existingMatch >= 0) {
          cart[existingMatch].qty++;
        } else {
          cart.add(item.copyWith(
              internalId: DateTime.now().millisecondsSinceEpoch,
              qty: 1,
              notes: newNote,
              course: newCourse,
              selectedExtras: newExtras));
        }
      } else {
        final existingMatch = cart.indexWhere((c) =>
            c != item &&
            c.id == item.id &&
            c.notes == newNote &&
            c.course == newCourse &&
            _areExtrasEqual(c.selectedExtras, newExtras));

        if (existingMatch >= 0) {
          cart[existingMatch].qty++;
          cart.remove(item);
        } else {
          item.notes = newNote;
          item.course = newCourse;
          item.selectedExtras = newExtras;
        }
      }
    });
  }

  void _handleBack() {
    if (cart.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cWhite,
          title: const Text("Modifiche non salvate"),
          content: const Text("Vuoi uscire senza inviare la comanda?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Annulla")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cRose500,
                  foregroundColor: AppColors.cWhite),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onBack();
              },
              child: const Text("Esci"),
            )
          ],
        ),
      );
    } else {
      widget.onBack();
    }
  }

  void _openEditDialog(CartItem item) {
    noteController.text = item.notes;
    Course selectedCourse = item.course;
    List<Extra> currentSelectedExtras = List.from(item.selectedExtras);

    final menuItem = menuItems.firstWhere((m) => m.id == item.id,
        orElse: () => menuItems[0]);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.cWhite,
            surfaceTintColor: AppColors.cWhite,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Modifica",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx))
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text("Sposta in:",
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cSlate500,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: Course.values.map((course) {
                      final isSel = selectedCourse == course;
                      return ChoiceChip(
                        label: Text(course.label,
                            style: TextStyle(
                                fontSize: 12,
                                color: isSel
                                    ? AppColors.cWhite
                                    : AppColors.cSlate800)),
                        selected: isSel,
                        selectedColor: AppColors.cIndigo600,
                        backgroundColor: AppColors.cSlate100,
                        side: BorderSide.none,
                        onSelected: (v) =>
                            setStateDialog(() => selectedCourse = course),
                      );
                    }).toList(),
                  ),
                  if (menuItem.availableExtras.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text("Aggiunte:",
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.cSlate500,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: menuItem.availableExtras.map((extra) {
                        final isSelected =
                            currentSelectedExtras.any((e) => e.id == extra.id);
                        return FilterChip(
                          label: Text(
                              "${extra.name} (+€${extra.price.toStringAsFixed(2)})"),
                          selected: isSelected,
                          onSelected: (selected) {
                            setStateDialog(() {
                              if (selected) {
                                currentSelectedExtras.add(extra);
                              } else {
                                currentSelectedExtras
                                    .removeWhere((e) => e.id == extra.id);
                              }
                            });
                          },
                          backgroundColor: AppColors.cSlate50,
                          selectedColor: AppColors.cAmber100,
                          checkmarkColor: AppColors.cAmber700,
                          labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.cAmber700
                                  : AppColors.cSlate800,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                          side: BorderSide(
                              color: isSelected
                                  ? AppColors.cAmber700
                                  : AppColors.cSlate200),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text("Note Cucina:",
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cSlate500,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Es. No cipolla...",
                      filled: true,
                      fillColor: AppColors.cSlate50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cIndigo600,
                  foregroundColor: AppColors.cWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _saveItemChanges(item, noteController.text, selectedCourse,
                      currentSelectedExtras);
                  Navigator.pop(ctx);
                },
                child: const Text("Salva Modifiche"),
              )
            ],
          );
        });
      },
    );
  }

  // --- UI BUILDING ---

  void _toggleProductExpansion(int itemId) {
    setState(() {
      if (_expandedItems.contains(itemId)) {
        _expandedItems.remove(itemId);
      } else {
        _expandedItems.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _maxHeight = size.height * 0.75;

    // TAB CONTROLLER per Menu vs Storico
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.cWhite,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.cSlate100))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: AppColors.cSlate500),
                            onPressed: _handleBack),
                        Column(
                          children: [
                            Text("Tavolo ${widget.table.name}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cSlate800)),
                            Text("${widget.table.guests} Coperti",
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.cSlate500)),
                          ],
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                // TAB BAR (Menu / Al Tavolo)
                TabBar(
                  labelColor: AppColors.cIndigo600,
                  unselectedLabelColor: AppColors.cSlate500,
                  indicatorColor: AppColors.cIndigo600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    const Tab(text: "MENU"),
                    Tab(text: "AL TAVOLO (${widget.table.orders.length})"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: MENU (Logica Esistente)
                      _buildMenuTab(),

                      // TAB 2: STORICO (Read-Only)
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
            if (cart.isNotEmpty) _buildBackdrop(),
            if (cart.isNotEmpty) _buildCartSheet(),
            if (cart.isNotEmpty) _buildSendButton(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: MENU COMPLETO ---
  Widget _buildMenuTab() {
    return Column(
      children: [
        // BARRA DI RICERCA
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Cerca prodotto...",
              prefixIcon: const Icon(Icons.search, color: AppColors.cSlate400),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => searchController.clear())
                  : null,
              filled: true,
              fillColor: AppColors.cSlate50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),

        // BARRA USCITE
        Container(
          height: 50,
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.cSlate100))),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: Course.values.length,
            itemBuilder: (ctx, idx) {
              final course = Course.values[idx];
              final isActive = activeCourse == course;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ActionChip(
                  label: Text(course.label),
                  backgroundColor:
                      isActive ? AppColors.cIndigo600 : AppColors.cSlate50,
                  labelStyle: TextStyle(
                      color: isActive ? AppColors.cWhite : AppColors.cSlate600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () => setState(() => activeCourse = course),
                ),
              );
            },
          ),
        ),

        // CATEGORIE
        if (searchQuery.isEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: categories.map((cat) {
                final isActive = activeCategory == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(() => activeCategory = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppColors.cSlate800 : AppColors.cWhite,
                        border: Border.all(
                            color: isActive
                                ? AppColors.cSlate800
                                : AppColors.cSlate200),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(cat.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isActive
                                  ? AppColors.cWhite
                                  : AppColors.cSlate600)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // LISTA PRODOTTI
        Expanded(
          child: Container(
            color: AppColors.cSlate50,
            child: getFilteredItems().isEmpty
                ? const Center(
                    child: Text("Nessun prodotto trovato",
                        style: TextStyle(color: AppColors.cSlate400)))
                : ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 120),
                    itemCount: getFilteredItems().length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = getFilteredItems()[index];
                      final totalQty = cart
                          .where((c) => c.id == item.id)
                          .fold(0, (sum, c) => sum + c.qty);
                      final isExpanded = _expandedItems.contains(item.id);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: AppColors.cWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isExpanded
                                  ? AppColors.cIndigo600.withOpacity(0.3)
                                  : AppColors.cSlate200),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.cBlack.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _addToCart(item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          item.imageUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                                width: 64,
                                                height: 64,
                                                color: AppColors.cSlate100,
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    color:
                                                        AppColors.cSlate400));
                                          },
                                        )),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _toggleProductExpansion(item.id),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(item.name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: AppColors
                                                            .cSlate800))),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 20,
                                                  color: AppColors.cSlate400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _addToCart(item),
                                        child: Text(
                                            "€ ${item.price.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.cIndigo600)),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _addToCart(item),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(8),
                                    child: totalQty > 0
                                        ? Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                                color: AppColors.cIndigo600,
                                                shape: BoxShape.circle),
                                            alignment: Alignment.center,
                                            child: Text("$totalQty",
                                                style: const TextStyle(
                                                    color: AppColors.cWhite,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )
                                        : Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                                color: AppColors.cSlate100,
                                                shape: BoxShape.circle),
                                            child: const Icon(Icons.add,
                                                size: 18,
                                                color: AppColors.cSlate400),
                                          ),
                                  ),
                                )
                              ],
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox(
                                  height: 0, width: double.infinity),
                              secondChild: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: AppColors.cSlate100)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    const Text("INGREDIENTI",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.cSlate400,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: item.ingredients
                                          .map((ing) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: AppColors.cSlate50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color: AppColors
                                                            .cSlate200)),
                                                child: Text(ing,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .cSlate600)),
                                              ))
                                          .toList(),
                                    ),
                                    if (item.allergens.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Text("ALLERGENI",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.cRose500,
                                              letterSpacing: 1)),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: item.allergens
                                            .map((alg) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: AppColors.cRose50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                          color: AppColors
                                                              .cRose500
                                                              .withOpacity(
                                                                  0.2))),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                          Icons.warning_amber,
                                                          size: 12,
                                                          color: AppColors
                                                              .cRose500),
                                                      const SizedBox(width: 4),
                                                      Text(alg,
                                                          style: const TextStyle(
                                                              fontSize: 11,
                                                              color: AppColors
                                                                  .cRose500,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    const Text(
                                        "In caso di allergie gravi, avvisare sempre lo chef.",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.cSlate400)),
                                  ],
                                ),
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: STORICO (READ ONLY) ---
  Widget _buildHistoryTab() {
    if (widget.table.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long, size: 64, color: AppColors.cSlate200),
            SizedBox(height: 16),
            Text("Nessun ordine inviato",
                style: TextStyle(
                    color: AppColors.cSlate400, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.table.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = widget.table.orders[index];
        bool hasExtras = item.selectedExtras.isNotEmpty;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cSlate200),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.cSlate100,
                    borderRadius: BorderRadius.circular(8)),
                child: Text("${item.qty}x",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cSlate600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.cSlate800)),
                    if (hasExtras)
                      Text(
                          item.selectedExtras
                              .map((e) => "+ ${e.name}")
                              .join(", "),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.cSlate500)),
                    if (item.notes.isNotEmpty)
                      Text(item.notes,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.cAmber700,
                              fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Text("€ ${(item.totalPrice).toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.cSlate600)),
            ],
          ),
        );
      },
    );
  }

  List<MenuItem> getFilteredItems() {
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final results = menuItems.where((i) {
        final nameMatch = i.name.toLowerCase().contains(query);
        final ingredientMatch =
            i.ingredients.any((ing) => ing.toLowerCase().contains(query));
        return nameMatch || ingredientMatch;
      }).toList();

      results.sort((a, b) {
        final nameA = a.name.toLowerCase();
        final nameB = b.name.toLowerCase();

        final aStartsWith = nameA.startsWith(query);
        final bStartsWith = nameB.startsWith(query);
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        final aNameContains = nameA.contains(query);
        final bNameContains = nameB.contains(query);
        if (aNameContains && !bNameContains) return -1;
        if (!aNameContains && bNameContains) return 1;

        return nameA.compareTo(nameB);
      });

      return results;
    }
    if (activeCategory == 'fav') {
      return menuItems.where((i) => i.popular).toList();
    }
    return menuItems.where((i) => i.category == activeCategory).toList();
  }

  Widget _buildBackdrop() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: _controller.value == 0,
          child: GestureDetector(
            onTap: () {
              _controller.animateTo(0, curve: Curves.easeOutQuint);
              _isExpanded = false;
            },
            child: Container(
                color: AppColors.cBlack
                    .withOpacity(0.4 * _controller.value)),
          ),
        );
      },
    );
  }

  Widget _buildCartSheet() {
    // Group items by course for the cart display
    Map<Course, List<CartItem>> groupedCart = {};
    for (var c in Course.values) {
      groupedCart[c] = cart.where((item) => item.course == c).toList();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offset = _maxHeight - _minHeight;
        double translateY = offset * (1 - _controller.value);
        return Positioned(
          height: _maxHeight,
          left: 0,
          right: 0,
          bottom: -translateY,
          child: child!,
        );
      },
      child: GestureDetector(
        onVerticalDragUpdate: (d) =>
            _controller.value -= d.primaryDelta! / (_maxHeight - _minHeight),
        onVerticalDragEnd: (d) {
          if (_controller.value > 0.3) {
            _controller.animateTo(1, curve: Curves.easeOutQuint);
            _isExpanded = true;
          } else {
            _controller.animateTo(0, curve: Curves.easeOutQuint);
            _isExpanded = false;
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.cWhite,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 20)
              ]),
          child: Column(
            children: [
              Container(
                height: _minHeight,
                color: AppColors.cTransparent,
                child: Column(children: [
                  const SizedBox(height: 12),
                  Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                          color: AppColors.cSlate200,
                          borderRadius: BorderRadius.circular(3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.shopping_bag,
                              color: AppColors.cIndigo600),
                          const SizedBox(width: 12),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_isExpanded ? "Nuovo Ordine" : "Comanda",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "${cart.fold(0, (s, i) => s + i.qty)} Articoli",
                                    style: const TextStyle(
                                        color: AppColors.cSlate500,
                                        fontSize: 12)),
                              ]),
                        ]),
                        Text(
                            "€ ${cart.fold(0.0, (s, i) => s + (i.unitPrice * i.qty)).toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ],
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Container(
                  color: AppColors.cSlate50,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (var course in Course.values)
                        if (groupedCart[course]!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(course.label.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cSlate500,
                                    letterSpacing: 1)),
                          ),
                          ...groupedCart[course]!
                              .map((item) => _buildCartItemRow(item)),
                          const SizedBox(height: 8),
                        ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item) {
    bool hasExtras = item.selectedExtras.isNotEmpty;
    bool hasNotes = item.notes.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (hasNotes || hasExtras) ? AppColors.cAmber50 : AppColors.cWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (hasNotes || hasExtras)
                ? AppColors.cAmber100
                : AppColors.cSlate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("€ ${(item.unitPrice * item.qty).toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.cSlate500)),
            ],
          ),
          if (hasExtras)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: item.selectedExtras
                    .map((e) => Text("+${e.name}",
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.cAmber700,
                            fontWeight: FontWeight.bold)))
                    .toList(),
              ),
            ),
          if (hasNotes)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      size: 12, color: AppColors.cAmber700),
                  const SizedBox(width: 4),
                  Text(item.notes,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.cAmber700))
                ])),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.cSlate100,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  QuantityButton(
                      icon: Icons.remove, onTap: () => _updateQty(item, -1)),
                  Text("${item.qty}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  QuantityButton(
                      icon: Icons.add, onTap: () => _updateQty(item, 1)),
                ]),
              ),
              Row(children: [
                GestureDetector(
                  onTap: () => _openEditDialog(item),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.cSlate100,
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(children: const [
                      Icon(Icons.edit, size: 14, color: AppColors.cSlate600),
                      SizedBox(width: 4),
                      Text("MODIFICA",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cSlate600))
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _removeItem(item),
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.cRose50,
                          borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.cRose500)),
                ),
              ]),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, 100 * (1 - _controller.value)),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.cWhite,
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cEmerald500,
                        foregroundColor: AppColors.cWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () => widget.onSuccess(cart),
                    icon: const Icon(Icons.send),
                    label: const Text("INVIA CUCINA",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  )),
            ),
          ),
        );
      },
    );
  }
}
