import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/core/utils/extensions.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';

import '../../../../data/models/menu/menu_item.dart';
import '../../../../data/models/menu/course.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';

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

  void _addToCart(MenuItem item, Course course) {
    ref.read(cartProvider.notifier).addItem(item, course);
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

  List<MenuItem> _getFilteredItems(
      List<MenuItem> allItems, String categoryId) {
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      return allItems.where((item) {
        final nameMatch = item.name.toLowerCase().contains(query);
        final ingredientMatch = item.ingredients
            .any((ing) => ing.name.toLowerCase().contains(query));
        return nameMatch || ingredientMatch;
      }).toList();
    }
    if (categoryId == 'ALL') {
      return allItems;
    }
    return allItems.where((item) => item.category.id == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    // Watch all data from the new providers
    final menuData = ref.watch(menuDataProvider);
    final allItems = menuData.value?.menuItems ?? [];
    final allCategories = menuData.value?.categories ?? [];
    final allCourses = menuData.value?.courses ?? [];
    final cart = ref.watch(cartProvider);

    // Set default active course if not set
    if (_activeCourse == null && allCourses.isNotEmpty) {
      _activeCourse = allCourses.first;
    }

    final filteredItems = _getFilteredItems(allItems, _activeCategoryId);

    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 800 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.labelSearch,
                  prefixIcon:
                      Icon(Icons.search, color: colors.textTertiary, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _searchController.clear())
                      : null,
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
            ),

            // COURSES BAR
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.divider))),
              alignment: Alignment.center,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: allCourses.length,
                itemBuilder: (ctx, idx) {
                  final course = allCourses[idx];
                  final isActive = _activeCourse?.id == course.id;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ActionChip(
                      label: Text(course.name,
                          style: const TextStyle(fontSize: 12)),
                      backgroundColor:
                          isActive ? colors.primary : colors.background,
                      labelStyle: TextStyle(
                          color: isActive
                              ? colors.onPrimary
                              : colors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () => setState(() => _activeCourse = course),
                    ),
                  );
                },
              ),
            ),

            // CATEGORIES
            if (_searchQuery.isEmpty)
              ScrollConfiguration(
                behavior: _MyCustomScrollBehavior(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _buildCategoryPill(
                        id: 'ALL',
                        name: AppLocalizations.of(context)!.labelAll,
                        isActive: _activeCategoryId == 'ALL',
                      ),
                      ...allCategories.map((cat) {
                        return _buildCategoryPill(
                          id: cat.id,
                          name: cat.name,
                          isActive: _activeCategoryId == cat.id,
                        );
                      }),
                    ],
                  ),
                ),
              ),

            if (_searchQuery.isEmpty) Divider(color: colors.divider, height: 1),

            // PRODUCTS LIST
            Expanded(
              child: Container(
                color: colors.background,
                child: menuData.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredItems.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.labelNoProducts,
                                style: TextStyle(
                                    color: colors.textTertiary,
                                    fontSize: 14)))
                        : ScrollConfiguration(
                            behavior: _MyCustomScrollBehavior(),
                            child: ListView.separated(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 16, bottom: 120),
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final totalQty = cart
                                    .where((c) => c.item.id == item.id)
                                    .fold(0, (sum, c) => sum + c.quantity);
                                final isExpanded = _expandedItems.contains(item.id);

                                return _ProductCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  totalQty: totalQty,
                                  isExpanded: isExpanded,
                                  onAdd: () {
                                    if (_activeCourse != null) {
                                      _addToCart(item, _activeCourse!);
                                    }
                                  },
                                  onExpand: () =>
                                      _toggleProductExpansion(item.id),
                                  ref: ref
                                );
                              },
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(
      {required String id, required String name, required bool isActive}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: () => setState(() => _activeCategoryId = id),
        label: Text(name),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isActive ? colors.onSecondary : colors.textSecondary,
        ),
        backgroundColor: isActive ? colors.secondary : colors.surface,
        side: BorderSide(color: isActive ? colors.secondary : colors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics();
  }
}

class _ProductCard extends StatelessWidget {
  final MenuItem item;
  final int totalQty;
  final bool isExpanded;
  final VoidCallback onAdd;
  final VoidCallback onExpand;
  final WidgetRef ref;

  const _ProductCard({
    super.key,
    required this.item,
    required this.totalQty,
    required this.isExpanded,
    required this.onAdd,
    required this.onExpand,
    required this.ref
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: colors.shadow.withValues(alpha:0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isExpanded ? colors.primary.withValues(alpha:0.5) : colors.divider),
        ),
        child: Column(
          children: [
            _buildMainTile(context),
            _buildExpansionTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTile(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onExpand,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Row(
        children: [
          // Image with tap to add
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkResponse(
              onTap: onAdd,
              radius: 38,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                    width: 64,
                    height: 64,
                    color: colors.background,
                    child: item.image != null
                        ? Image.network(item.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.restaurant,
                                color: colors.textTertiary, size: 24))
                        : Icon(Icons.restaurant,
                            color: colors.textTertiary, size: 24)),
              ),
            ),
          ),
          // Name and Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text(item.price.toCurrency(ref),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                        fontSize: 14)),
              ],
            ),
          ),
          // Add button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkResponse(
              onTap: onAdd,
              radius: 24,
              child: totalQty > 0
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: colors.primary, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text("$totalQty",
                          style: TextStyle(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)))
                  : Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: colors.background, shape: BoxShape.circle),
                      child: Icon(Icons.add,
                          size: 18, color: colors.textTertiary)),
            ),
          ),
          // Expansion Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20,
                color: colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(height: 0, width: double.infinity),
      secondChild: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colors.divider))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(item.description!,
                style:
                    TextStyle(fontSize: 12, color: context.colors.textSecondary)),
          ],
          if (item.ingredients.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.labelIngredients,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textTertiary,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.ingredients
                    .map((ing) => _buildTag(context, ing.name,
                        context.colors.background, context.colors.textSecondary))
                    .toList()),
          ],
          if (item.allergens.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.labelAllergens,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colors.danger,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.allergens
                    .map((alg) => _buildTag(context, alg.name,
                        context.colors.dangerContainer, context.colors.danger,
                        isWarning: true))
                    .toList()),
          ],
        ]),
      ),
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bg, Color textCol,
      {bool isWarning = false}) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: isWarning
                  ? textCol.withValues(alpha:0.2)
                  : colors.divider)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isWarning) ...[
          Icon(Icons.warning_amber, size: 12, color: colors.danger),
          const SizedBox(width: 4)
        ],
        Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11,
                    color: textCol,
                    fontWeight:
                        isWarning ? FontWeight.bold : FontWeight.normal)))
      ]),
    );
  }
}

