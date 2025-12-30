import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/themes.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/course.dart';
import '../../../../shared/widgets/quantity_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import 'item_edit_dialog.dart'; // Importa il widget

class CartSheet extends ConsumerStatefulWidget {
  final AnimationController controller;
  final double minHeight;
  final double maxHeight;
  final bool isExpanded;
  final Function(bool) onExpandChange;

  const CartSheet({
    super.key,
    required this.controller,
    required this.minHeight,
    required this.maxHeight,
    required this.isExpanded,
    required this.onExpandChange,
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
    final menuItem = menuItems.firstWhere((m) => m.id == item.id, orElse: () => menuItems[0]);

    showDialog(
      context: context,
      builder: (ctx) => ItemEditDialog(
        cartItem: item,
        menuItem: menuItem,
        onSave: (qty, note, course, extras) {
          // Passiamo anche la quantità al provider, che ora supporta la modifica/split
          ref.read(cartProvider.notifier).updateItemConfig(item, qty, note, course, extras);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // ... (Resto del file build identico a prima, usando _openEditDialog aggiornato) ...
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    Map<Course, List<CartItem>> groupedCart = {};
    for (var c in Course.values) {
      groupedCart[c] = cart.where((item) => item.course == c).toList();
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        double offset = widget.maxHeight - widget.minHeight;
        double translateY = offset * (1 - widget.controller.value);
        return Positioned(
          height: widget.maxHeight, left: 0, right: 0, bottom: -translateY,
          child: child!,
        );
      },
      child: GestureDetector(
        onVerticalDragUpdate: (d) => widget.controller.value -= d.primaryDelta! / (widget.maxHeight - widget.minHeight),
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
          decoration: BoxDecoration(color: AppColors.cWhite, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
          child: Column(
            children: [
              Container(
                height: widget.minHeight, color: Colors.transparent,
                child: Column(children: [
                  const SizedBox(height: 12),
                  Container(width: 48, height: 6, decoration: BoxDecoration(color: AppColors.cSlate200, borderRadius: BorderRadius.circular(3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.shopping_bag, color: AppColors.cIndigo600),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.isExpanded ? "Nuovo Ordine" : "Comanda", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${cart.fold(0, (s, i) => s + i.qty)} Articoli", style: const TextStyle(color: AppColors.cSlate500, fontSize: 12)),
                        ]),
                      ]),
                      Text("€ ${cart.fold(0.0, (s, i) => s + (i.unitPrice * i.qty)).toStringAsFixed(2)}", style: const TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
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
                          Padding(padding: const EdgeInsets.only(bottom: 8, top: 8), child: Text(course.label.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.cSlate500, letterSpacing: 1))),
                          ...groupedCart[course]!.map((item) => _buildCartItemRow(item)),
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
      decoration: BoxDecoration(color: (hasNotes || hasExtras) ? AppColors.cAmber50 : AppColors.cWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: (hasNotes || hasExtras) ? AppColors.cAmber100 : AppColors.cSlate200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("€ ${(item.unitPrice * item.qty).toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: AppColors.cSlate500)),
        ]),
        if (hasExtras) Padding(padding: const EdgeInsets.only(top: 4), child: Wrap(spacing: 4, children: item.selectedExtras.map((e) => Text("+${e.name}", style: const TextStyle(fontSize: 11, color: AppColors.cAmber700, fontWeight: FontWeight.bold))).toList())),
        if (hasNotes) Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.error_outline, size: 12, color: AppColors.cAmber700), const SizedBox(width: 4), Text(item.notes, style: const TextStyle(fontSize: 12, color: AppColors.cAmber700))])),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(decoration: BoxDecoration(color: AppColors.cSlate100, borderRadius: BorderRadius.circular(8)), child: Row(children: [
            QuantityButton(icon: Icons.remove, onTap: () => _updateQty(item.internalId, -1)),
            Text("${item.qty}", style: const TextStyle(fontWeight: FontWeight.bold)),
            QuantityButton(icon: Icons.add, onTap: () => _updateQty(item.internalId, 1)),
          ])),
          Row(children: [
            GestureDetector(onTap: () => _openEditDialog(item), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.cSlate100, borderRadius: BorderRadius.circular(6)), child: Row(children: const [Icon(Icons.edit, size: 14, color: AppColors.cSlate600), SizedBox(width: 4), Text("MODIFICA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cSlate600))]))),
            const SizedBox(width: 8),
            GestureDetector(onTap: () => ref.read(cartProvider.notifier).removeItem(item.internalId), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.cRose50, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.delete_outline, size: 16, color: AppColors.cRose500))),
          ]),
        ]),
      ]),
    );
  }
}