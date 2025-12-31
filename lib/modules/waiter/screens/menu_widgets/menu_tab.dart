import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/config/restaurant_settings.dart';
import 'package:orderly/l10n/app_localizations.dart';

import '../../../../config/themes.dart';
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
              prefixIcon: const Icon(Icons.search, color: AppColors.cSlate400),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close), onPressed: () => searchController.clear())
                  : null,
              filled: true,
              fillColor: AppColors.cSlate50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),

        // BARRA USCITE
        Container(
          height: 50,
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.cSlate100))),
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
                  backgroundColor: isActive ? AppColors.cIndigo600 : AppColors.cSlate50,
                  labelStyle: TextStyle(color: isActive ? AppColors.cWhite : AppColors.cSlate600, fontWeight: FontWeight.bold, fontSize: 12),
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
            color: AppColors.cSlate50,
            child: filteredItems.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.labelNoProducts, style: TextStyle(color: AppColors.cSlate400)))
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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => activeCategory = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cSlate800 : AppColors.cWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isActive ? AppColors.cSlate800 : AppColors.cSlate200),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? AppColors.cWhite : AppColors.cSlate600,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.cWhite, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpanded ? AppColors.cIndigo600.withValues(alpha: 0.3) : AppColors.cSlate200),
        boxShadow: [BoxShadow(color: AppColors.cBlack.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
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
                        width: 64, height: 64, color: AppColors.cSlate100,
                        child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            // CachedNetworkImage sarebbe meglio in un'app reale
                            errorBuilder: (_,__,___)=>const Icon(Icons.broken_image, color: AppColors.cSlate400)
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
                          Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.cSlate800))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: AppColors.cSlate400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onAdd,
                      child: Text(item.price.toCurrency(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.cIndigo600)),
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
                      ? Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.cIndigo600, shape: BoxShape.circle), alignment: Alignment.center, child: Text("$totalQty", style: const TextStyle(color: AppColors.cWhite, fontWeight: FontWeight.bold)))
                      : Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.cSlate100, shape: BoxShape.circle), child: const Icon(Icons.add, size: 18, color: AppColors.cSlate400)),
                ),
              )
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.cSlate100))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.labelIngredients, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cSlate400, letterSpacing: 1)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: item.ingredients.map((ing) => _buildTag(ing, AppColors.cSlate50, AppColors.cSlate600)).toList()),
                if (item.allergens.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.labelAllergens, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cRose500, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: item.allergens.map((alg) => _buildTag(alg, AppColors.cRose50, AppColors.cRose500, isWarning: true)).toList()),
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

  Widget _buildTag(String text, Color bg, Color textCol, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: isWarning ? textCol.withValues(alpha: 0.2) : AppColors.cSlate200)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if(isWarning) ...[const Icon(Icons.warning_amber, size: 12, color: AppColors.cRose500), const SizedBox(width: 4)],
        Text(text, style: TextStyle(fontSize: 11, color: textCol, fontWeight: isWarning ? FontWeight.bold : FontWeight.normal))
      ]),
    );
  }
}