import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';

import '../../../../data/models/cart_item.dart';
import '../../../../data/models/course.dart';
import '../../../../shared/widgets/quantity_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import 'item_edit_dialog.dart';

class CartSheet extends ConsumerStatefulWidget {
  final AnimationController controller;
  final double minHeight;
  final double maxHeight;
  final bool isExpanded;
  final Function(bool) onExpandChange;
  final Function onSendOrder;

  const CartSheet({
    super.key,
    required this.controller,
    required this.minHeight,
    required this.maxHeight,
    required this.isExpanded,
    required this.onExpandChange,
    required this.onSendOrder,
  });

  @override
  ConsumerState<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends ConsumerState<CartSheet> {
  void _updateQty(int internalId, int delta) {
    if (delta > 0) {
      ref.read(cartProvider.notifier).incrementQty(internalId);
    } else {
      ref.read(cartProvider.notifier).decrementQty(internalId);
    }
  }

  void _openEditDialog(CartItem item) {
    final menuItems = ref.read(menuProvider);
    final menuItem = menuItems.firstWhere((m) => m.id == item.id,
        orElse: () => menuItems[0]);

    showDialog(
      context: context,
      builder: (ctx) => ItemEditDialog(
        cartItem: item,
        menuItem: menuItem,
        onSave: (qty, note, course, extras) {
          ref
              .read(cartProvider.notifier)
              .updateItemConfig(item, qty, note, course, extras);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cart = ref.watch(cartProvider);

    // --- LOGICA RESPONSIVE ---
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide > 600;
    // Limitiamo a 600px su tablet, altrimenti infinito (tutto lo schermo) su telefono
    final double maxContentWidth = isTablet ? 600.0 : double.infinity;

    Map<Course, List<CartItem>> groupedCart = {};
    for (var c in Course.values) {
      groupedCart[c] = cart.where((item) => item.course == c).toList();
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        double offset = widget.maxHeight - widget.minHeight;
        double translateY = offset * (1 - widget.controller.value);

        // Il Positioned deve occupare tutta la larghezza per gestire l'animazione correttamente
        return Positioned(
          height: widget.maxHeight,
          left: 0,
          right: 0,
          bottom: -translateY,
          // Qui usiamo Center + ConstrainedBox per limitare la larghezza del contenuto effettivo
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: child!,
            ),
          ),
        );
      },
      child: GestureDetector(
        onVerticalDragUpdate: (d) => widget.controller.value -=
            d.primaryDelta! / (widget.maxHeight - widget.minHeight),
        onVerticalDragEnd: (d) {
          if (widget.controller.value > 0.3) {
            widget.controller.animateTo(1, curve: Curves.easeOutQuint);
            widget.onExpandChange(true);
          } else {
            widget.controller.animateTo(0, curve: Curves.easeOutQuint);
            widget.onExpandChange(false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 20)]),
          child: Column(
            children: [
              // --- HEADER DEL CARRELLO ---
              GestureDetector(
                onTap: () {
                  if (widget.isExpanded) {
                    widget.controller.animateTo(0, curve: Curves.easeOutQuint);
                    widget.onExpandChange(false);
                  } else {
                    widget.controller.animateTo(1, curve: Curves.easeOutQuint);
                    widget.onExpandChange(true);
                  }
                },
                child: Container(
                  height: widget.minHeight,
                  color: Colors.transparent,
                  child: Column(children: [
                    const SizedBox(height: 12),
                    // Maniglia
                    Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                            color: colors.divider,
                            borderRadius: BorderRadius.circular(3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(Icons.shopping_bag,
                                  color: colors.primary, size: 20),
                              const SizedBox(width: 12),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context)!.cartSheetTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Text(
                                        AppLocalizations.of(context)!.cartSheetItemsCountLabel(cart.fold(0, (s, i) => s + i.qty)),
                                        style: TextStyle(
                                            color: colors.textSecondary,
                                            fontSize: 12)),
                                  ]),
                            ]),
                            Row(
                              children: [
                                Text(
                                    "€ ${cart.fold(0.0, (s, i) => s + (i.unitPrice * i.qty)).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                // Mostra il pulsante invia rapido solo se non è espanso
                                if (!widget.isExpanded) ... [
                                  const SizedBox(width: 16),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: colors.success,
                                    child: IconButton(
                                        icon: Icon(Icons.send,
                                            color: colors.textInverse, size: 18),
                                        onPressed: () => widget.onSendOrder()),
                                  ),
                                ]
                              ],
                            ),
                          ]),
                    ),
                  ]),
                ),
              ),

              // --- LISTA PRODOTTI ---
              Expanded(
                child: Container(
                  color: colors.background,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (var course in Course.values)
                        if (groupedCart[course]!.isNotEmpty) ...[
                          Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 8),
                              child: Text(course.label.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textSecondary,
                                      letterSpacing: 1))),
                          ...groupedCart[course]!
                              .map((item) => _buildCartItemRow(context, item)),
                          const SizedBox(height: 8),
                        ],
                      // Spazio extra in fondo per evitare che l'ultimo elemento sia coperto dal pulsante floating (se presente)
                      const SizedBox(height: 100),
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

  Widget _buildCartItemRow(BuildContext context, CartItem item) {
    final colors = context.colors;
    bool hasExtras = item.selectedExtras.isNotEmpty;
    bool hasNotes = item.notes.isNotEmpty;

    Color cardColor = (hasNotes || hasExtras) ? colors.warningContainer : colors.surface;
    Color borderColor = (hasNotes || hasExtras) ? colors.warningContainer : colors.divider;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 8),
            Text("€ ${(item.unitPrice * item.qty).toStringAsFixed(2)}",
                style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ]),
          if (hasExtras)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.selectedExtras
                        .map((e) => Text("+${e.name}",
                        style: TextStyle(
                            fontSize: 11,
                            color: colors.warning,
                            fontWeight: FontWeight.bold)))
                        .toList())),
          if (hasNotes)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  Icon(Icons.error_outline, size: 12, color: colors.warning),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.notes,
                        style: TextStyle(fontSize: 12, color: colors.warning)),
                  )
                ])),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  QuantityButton(
                      icon: Icons.remove,
                      onTap: () => _updateQty(item.internalId, -1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("${item.qty}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  QuantityButton(
                      icon: Icons.add,
                      onTap: () => _updateQty(item.internalId, 1)),
                ])),
            Row(children: [
              Material(
                color: colors.background,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => _openEditDialog(item),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Row(children: [
                        Icon(Icons.edit, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context)!.btnEdit,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.textSecondary))
                      ])),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: colors.dangerContainer,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => ref
                      .read(cartProvider.notifier)
                      .removeItem(item.internalId),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.delete_outline,
                          size: 16, color: colors.danger)),
                ),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }
}