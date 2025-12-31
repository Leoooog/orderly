import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/config/restaurant_settings.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';

import '../../../../data/models/menu_item.dart';
import '../../../../data/models/course.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';

class MenuTab extends ConsumerStatefulWidget {
  const MenuTab({super.key});

  @override
  ConsumerState<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<MenuTab> with AutomaticKeepAliveClientMixin {
  String activeCategory = '';
  Course activeCourse = Course.entree;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final Set<int> _expandedItems = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() => searchQuery = searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _addToCart(MenuItem item) {
    ref.read(cartProvider.notifier).addItem(item, activeCourse);
  }

  void _toggleProductExpansion(int itemId) {
    setState(() {
      if (_expandedItems.contains(itemId)) {
        _expandedItems.remove(itemId);
      } else {
        _expandedItems.add(itemId);
      }
    });
  }

  // MODIFICA 1: Gestione della categoria 'ALL'
  List<MenuItem> getFilteredItems(List<MenuItem> allItems, String category) {
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      return allItems.where((i) {
        return i.name.toLowerCase().contains(query) ||
            i.ingredients.any((ing) => ing.toLowerCase().contains(query));
      }).toList();
    }
    // Se la categoria è 'ALL', restituisci tutto, altrimenti filtra
    if (category == 'ALL') {
      return allItems;
    }
    return allItems.where((i) => i.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    final menuItemsList = ref.watch(menuProvider);
    final categoriesList = ref.watch(categoriesProvider);
    final cart = ref.watch(cartProvider);

    // MODIFICA 2: Default su 'ALL' se vuoto
    String currentCategory = activeCategory;
    if (currentCategory.isEmpty) {
      currentCategory = 'ALL';
    }

    final filteredItems = getFilteredItems(menuItemsList, currentCategory);

    return Column(
      children: [
        // BARRA DI RICERCA
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.labelSearch,
              prefixIcon: Icon(Icons.search, color: colors.textTertiary),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close), onPressed: () => searchController.clear())
                  : null,
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),

        // BARRA USCITE
        Container(
          height: 50,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.divider))),
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
                  backgroundColor: isActive ? colors.primary : colors.background,
                  labelStyle: TextStyle(color: isActive ? colors.onPrimary : colors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              children: [
                // MODIFICA 3: Aggiunta manuale del pulsante "Tutti"
                _buildCategoryPill(
                  id: 'ALL',
                  name: AppLocalizations.of(context)!.labelAll,
                  isActive: currentCategory == 'ALL',
                ),

                // Lista categorie reali
                ...categoriesList.map((cat) {
                  return _buildCategoryPill(
                    id: cat.id,
                    name: cat.name,
                    isActive: currentCategory == cat.id,
                  );
                }),
              ],
            ),
          ),

        // LISTA PRODOTTI
        Expanded(
          child: Container(
            color: colors.background,
            child: filteredItems.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.labelNoProducts, style: TextStyle(color: colors.textTertiary)))
                : ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final totalQty = cart.where((c) => c.id == item.id).fold(0, (sum, c) => sum + c.qty);
                final isExpanded = _expandedItems.contains(item.id);

                return _ProductCard(
                  key: ValueKey(item.id),
                  item: item,
                  totalQty: totalQty,
                  isExpanded: isExpanded,
                  onAdd: () => _addToCart(item),
                  onExpand: () => _toggleProductExpansion(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Helper per evitare duplicazione codice UI tra "Tutti" e le altre categorie
  Widget _buildCategoryPill({required String id, required String name, required bool isActive}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => activeCategory = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? colors.secondary : colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isActive ? colors.secondary : colors.divider),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? colors.onSecondary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// 4. Estratto in un widget Stateless per ridurre il lavoro del motore di rendering
class _ProductCard extends StatelessWidget {
  final MenuItem item;
  final int totalQty;
  final bool isExpanded;
  final VoidCallback onAdd;
  final VoidCallback onExpand;

  const _ProductCard({
    super.key,
    required this.item,
    required this.totalQty,
    required this.isExpanded,
    required this.onAdd,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpanded ? colors.borderExpanded : colors.divider),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAdd,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                        width: 64, height: 64, color: colors.background,
                        child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            // CachedNetworkImage sarebbe meglio in un'app reale
                            errorBuilder: (_,__,___)=> Icon(Icons.broken_image, color: colors.textTertiary)
                        )
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onExpand,
                      child: Row(
                        children: [
                          Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: colors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onAdd,
                      child: Text(item.price.toCurrency(), style: TextStyle(fontWeight: FontWeight.w600, color: colors.primary)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  child: totalQty > 0
                      ? Container(width: 32, height: 32, decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle), alignment: Alignment.center, child: Text("$totalQty", style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.bold)))
                      : Container(width: 32, height: 32, decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle), child: Icon(Icons.add, size: 18, color: colors.textTertiary)),
                ),
              )
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.labelIngredients, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textTertiary, letterSpacing: 1)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: item.ingredients.map((ing) => _buildTag(context, ing, colors.background, colors.textSecondary)).toList()),
                if (item.allergens.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.labelAllergens, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.danger, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: item.allergens.map((alg) => _buildTag(context, alg, colors.dangerContainer, colors.danger, isWarning: true)).toList()),
                ],
              ]),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bg, Color textCol, {bool isWarning = false}) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: isWarning ? textCol.withValues(alpha: 0.2) : colors.divider)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if(isWarning) ...[Icon(Icons.warning_amber, size: 12, color: colors.danger), const SizedBox(width: 4)],
        Text(text, style: TextStyle(fontSize: 11, color: textCol, fontWeight: isWarning ? FontWeight.bold : FontWeight.normal))
      ]),
    );
  }
}
