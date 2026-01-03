import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/config/orderly_colors.dart';
import 'package:orderly/l10n/app_localizations.dart';

import '../../../../data/models/local/cart_entry.dart'; // Assicurati di importare CartEntry
import '../../../../data/models/menu/course.dart';
// Modelli
import '../../../../data/models/menu/menu_item.dart';
import '../../providers/cart_provider.dart';
// Providers
import '../../providers/menu_provider.dart';
import '../widgets/product_card.dart';

class MenuTab extends ConsumerStatefulWidget {
  const MenuTab({super.key});

  @override
  ConsumerState<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<MenuTab>
    with AutomaticKeepAliveClientMixin {
  String _activeCategoryId = 'ALL';
  Course? _activeCourse;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Set<String> _expandedItems = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGICA CARRELLO AGGIORNATA ---

  void _onAddItem(MenuItem item) {
    if (_activeCourse == null) return;
    // Il notifier gestisce la creazione o l'incremento di una entry pulita
    ref.read(cartProvider.notifier).addItem(item, _activeCourse!);
  }

  void _onRemoveItem(MenuItem item) {
    final cart = ref.read(cartProvider);

    // Dobbiamo trovare QUALE entry decrementare, dato che potrebbero essercene diverse
    // per lo stesso prodotto (es. una normale, una con note).
    // Strategia:
    // 1. Cerchiamo l'ultima entry di questo item che corrisponde al corso attivo e non ha modifiche (priorità massima)
    // 2. Se non c'è, prendiamo l'ultima entry inserita con questo item ID (LIFO)

    CartEntry? candidate;

    try {
      // Cerca entry identica "pulita" nel corso attuale
      candidate = cart.lastWhere((e) =>
      e.item.id == item.id &&
          e.course.id == _activeCourse?.id &&
          (e.notes == null || e.notes!.isEmpty) &&
          e.selectedExtras.isEmpty &&
          e.removedIngredients.isEmpty
      );
    } catch (_) {
      // Fallback: cerca una qualsiasi entry con questo item ID
      try {
        candidate = cart.lastWhere((e) => e.item.id == item.id);
      } catch (_) {
        candidate = null;
      }
    }

    if (candidate != null) {
      ref.read(cartProvider.notifier).decrementQty(candidate.internalId);
    }
  }

  void _toggleProductExpansion(String itemId) {
    setState(() {
      if (_expandedItems.contains(itemId)) {
        _expandedItems.remove(itemId);
      } else {
        _expandedItems.add(itemId);
      }
    });
  }

  List<MenuItem> _getFilteredItems(List<MenuItem> allItems) {
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      return allItems.where((item) {
        final nameMatch = item.name.toLowerCase().contains(query);
        final codeMatch = item.id.toLowerCase().contains(query);
        final ingredientMatch = item.ingredients
            .any((ing) => ing.name.toLowerCase().contains(query));
        return nameMatch || ingredientMatch || codeMatch;
      }).toList();
    }

    if (_activeCategoryId == 'ALL') {
      return allItems;
    }
    return allItems.where((item) => item.category.id == _activeCategoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final menuDataAsync = ref.watch(menuDataProvider);

    return menuDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Errore caricamento menu: $err')),
      data: (menuData) {
        final allItems = menuData.menuItems;
        final allCategories = menuData.categories;
        final allCourses = menuData.courses;
        // Cart è una List<CartEntry>
        final List<CartEntry> cart = ref.watch(cartProvider);

        if (_activeCourse == null && allCourses.isNotEmpty) {
          _activeCourse = allCourses.first;
        }

        final filteredItems = _getFilteredItems(allItems);
        final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
        final double maxWidth = isTablet ? 900 : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CustomScrollView(
              slivers: [
                // 1. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.labelSearch,
                        prefixIcon: Icon(Icons.search,
                            color: colors.textTertiary, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            })
                            : null,
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.divider.withValues(alpha: 0.5))),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ),

                // 2. Courses Selector
                if (_searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: _CourseSelector(
                      courses: allCourses,
                      activeCourse: _activeCourse,
                      onSelect: (c) => setState(() => _activeCourse = c),
                    ),
                  ),

                // 3. Categories Selector
                if (_searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: _CategorySelector(
                      categories: allCategories,
                      activeCategoryId: _activeCategoryId,
                      onSelect: (id) => setState(() => _activeCategoryId = id),
                    ),
                  ),

                if (_searchQuery.isEmpty)
                  SliverToBoxAdapter(
                      child: Divider(color: colors.divider, height: 1)),

                // 4. Products List
                filteredItems.isEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fastfood_outlined,
                            size: 48, color: colors.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.labelNoProducts,
                          style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
                    : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final item = filteredItems[index];

                        // Calcolo quantità totale sommando le quantity delle CartEntry corrispondenti
                        final totalQty = cart
                            .where((c) => c.item.id == item.id)
                            .fold(0, (sum, c) => sum + c.quantity);

                        final isExpanded = _expandedItems.contains(item.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProductCard(
                            key: ValueKey(item.id),
                            item: item,
                            totalQty: totalQty,
                            isExpanded: isExpanded,
                            onAdd: () => _onAddItem(item),
                            onRemove: () => _onRemoveItem(item),
                            onExpand: () => _toggleProductExpansion(item.id),
                            ref: ref,
                          ),
                        );
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS SECONDARI
// -----------------------------------------------------------------------------

class _CourseSelector extends StatelessWidget {
  final List<Course> courses;
  final Course? activeCourse;
  final ValueChanged<Course> onSelect;

  const _CourseSelector({
    required this.courses,
    required this.activeCourse,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.divider.withValues(alpha: 0.5))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final course = courses[idx];
          final isActive = activeCourse?.id == course.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(course),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: isActive ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? colors.primary : colors.divider,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0,2))]
                        : null
                ),
                child: Text(
                  course.name,
                  style: TextStyle(
                    color: isActive ? colors.onPrimary : colors.textSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<dynamic> categories;
  final String activeCategoryId;
  final ValueChanged<String> onSelect;

  const _CategorySelector({
    required this.categories,
    required this.activeCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allItems = [
      (id: 'ALL', name: AppLocalizations.of(context)!.labelAll),
      ...categories.map((c) => (id: c.id as String, name: c.name as String)),
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: allItems.length,
        itemBuilder: (ctx, idx) {
          final cat = allItems[idx];
          final isActive = activeCategoryId == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(

              label: Text(cat.name),
              selected: isActive,
              onSelected: (_) => onSelect(cat.id),
              backgroundColor: colors.surface,
              selectedColor: colors.secondary,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isActive ? colors.onSecondary : colors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isActive ? Colors.transparent : colors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        },
      ),
    );
  }
}
