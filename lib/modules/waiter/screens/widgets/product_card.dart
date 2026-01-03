import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/orderly_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/menu/menu_item.dart';
import '../../../../l10n/app_localizations.dart';

class ProductCard extends StatelessWidget {
  final MenuItem item;
  final int totalQty;
  final bool isExpanded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onExpand;
  final WidgetRef ref;

  const ProductCard({
    super.key,
    required this.item,
    required this.totalQty,
    required this.isExpanded,
    required this.onAdd,
    required this.onRemove,
    required this.onExpand,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool hasOrder = totalQty > 0;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: colors.shadow.withValues(alpha: 0.08),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasOrder
                  ? colors.primary.withValues(alpha: 0.3)
                  : (isExpanded ? colors.divider : Colors.transparent),
              width: hasOrder ? 1.5 : 1
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onExpand,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  // 1. Allineamento verticale al centro per estetica migliore
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Immagine
                    _buildProductImage(context),

                    const SizedBox(width: 12),

                    // Info (Nome e Prezzo)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.2,
                                  color: colors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(item.price.toCurrency(ref),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                  fontSize: 15)),
                          // RIMOSSO: L'icona freccia che era qui sotto
                        ],
                      ),
                    ),

                    // Controlli Quantità
                    _buildQuantityControls(context, colors),

                    // 2. NUOVA POSIZIONE FRECCIA
                    const SizedBox(width: 12), // Spaziatura tra i bottoni e la freccia
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colors.textTertiary,
                      size: 24,
                    ),
                    const SizedBox(width: 4), // Margine destro minimo
                  ],
                ),
              ),
            ),

            // Dettagli Espandibili
            _buildExpansionTile(context),
          ],
        ),
      ),
    );
  }

  // ... (Il resto dei metodi _buildProductImage, _buildQuantityControls, etc. rimangono uguali)

  Widget _buildProductImage(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: item.image != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.restaurant_menu,
                  color: colors.textTertiary.withValues(alpha: 0.5), size: 28),
            ),
          )
              : Icon(Icons.restaurant_menu,
              color: colors.textTertiary.withValues(alpha: 0.5), size: 28),
        ),
        if (item.ingredients.any((i) => i.isFrozen))
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle
              ),
              child: Icon(Icons.ac_unit, size: 10, color: colors.primary),
            ),
          )
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context, dynamic colors) {
    final hasOrder = totalQty > 0;

    return Column(
      children: [
        if (hasOrder) ...[
          Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyBtn(icon: Icons.remove, onTap: onRemove, color: colors.danger),
                Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  alignment: Alignment.center,
                  child: Text("$totalQty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.textPrimary)),
                ),
                _QtyBtn(icon: Icons.add, onTap: onAdd, color: colors.primary),
              ],
            ),
          )
        ] else ...[
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(Icons.add, color: colors.onPrimary, size: 24),
              ),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildExpansionTile(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colors.divider.withValues(alpha: 0.5)))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          if (item.description != null && item.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(item.description!,
                  style: TextStyle(fontSize: 13, height: 1.4, color: context.colors.textSecondary)),
            ),

          if (item.ingredients.isNotEmpty) ...[
            Text(AppLocalizations.of(context)!.labelIngredients,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.ingredients
                    .map((ing) => _buildTag(context, ing.name,
                    context.colors.background, context.colors.textSecondary,
                    frozen: ing.isFrozen))
                    .toList()),
          ],

          if (item.allergens.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.labelAllergens,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colors.danger,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.allergens
                    .map((alg) => _buildTag(context, alg.name,
                    context.colors.dangerContainer.withValues(alpha: 0.3), context.colors.danger,
                    isWarning: true))
                    .toList()),
          ],
        ]),
      ),
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bg, Color textCol,
      {bool isWarning = false, bool frozen = false}) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: isWarning
                  ? textCol.withValues(alpha: 0.2)
                  : colors.divider)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (frozen) ...[
          Icon(Icons.ac_unit, size: 12, color: colors.primary),
          const SizedBox(width: 4)
        ],
        Text(text,
            style: TextStyle(
                fontSize: 12,
                color: textCol,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.w500))
      ]),
    );
  }
}


class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}