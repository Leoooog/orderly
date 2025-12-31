import 'package:flutter/material.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/course.dart';
import '../../../../data/models/extra.dart';
import '../../../../data/models/menu_item.dart';

class ItemEditDialog extends StatefulWidget {
  final CartItem cartItem;
  final MenuItem menuItem;
  // Callback aggiornata con qty
  final Function(int qty, String note, Course course, List<Extra> extras) onSave;

  const ItemEditDialog({
    super.key,
    required this.cartItem,
    required this.menuItem,
    required this.onSave,
  });

  @override
  State<ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<ItemEditDialog> {
  late TextEditingController _noteController;
  late Course _selectedCourse;
  late List<Extra> _currentExtras;
  late int _qtyToModify;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.cartItem.notes);
    _selectedCourse = widget.cartItem.course;
    _currentExtras = List.from(widget.cartItem.selectedExtras);
    // Di default, se stiamo modificando, partiamo col modificare 1 unità (per lo split)
    // oppure la quantità totale se è 1.
    _qtyToModify = 1;
    // Se preferisci che di default selezioni TUTTI quelli disponibili:
    // _qtyToModify = widget.cartItem.qty;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final int maxQty = widget.cartItem.qty;

    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context)!.labelEdit, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          IconButton(
            icon: Icon(Icons.close, size: 18),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
                AppLocalizations.of(context)!.cartEditingItem(widget.menuItem.name),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primary)
            ),
            SizedBox(height: 16),

            // --- SELETTORE QUANTITÀ (Solo se qty > 1) ---
            if (maxQty > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(AppLocalizations.of(context)!.cartEditingQuantity, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold))),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: _qtyToModify > 1 ? colors.primary : colors.textTertiary, size: 20),
                          onPressed: _qtyToModify > 1 ? () => setState(() => _qtyToModify--) : null
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(8)),
                        child: Text("$_qtyToModify / $maxQty", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                      ),
                      IconButton(
                          icon: Icon(Icons.add_circle_outline, color: _qtyToModify < maxQty ? colors.primary : colors.textTertiary, size: 20),
                          onPressed: _qtyToModify < maxQty ? () => setState(() => _qtyToModify++) : null
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],

            // --- SCELTA PORTATA ---
            Text(AppLocalizations.of(context)!.dialogMoveToCourse, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Course.values.map((course) {
                final isSel = _selectedCourse == course;
                return ChoiceChip(
                  label: Text(course.label, style: TextStyle(fontSize: 12, color: isSel ? colors.onPrimary : colors.textPrimary)),
                  selected: isSel,
                  selectedColor: colors.primary,
                  backgroundColor: colors.background,
                  side: BorderSide.none,
                  onSelected: (v) => setState(() => _selectedCourse = course),
                );
              }).toList(),
            ),

            // --- SCELTA EXTRA ---
            if (widget.menuItem.availableExtras.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.labelExtras, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.menuItem.availableExtras.map((extra) {
                  final isSelected = _currentExtras.any((e) => e.id == extra.id);
                  return FilterChip(
                    label: Text("${extra.name} (+€${extra.price.toStringAsFixed(2)})", style: TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _currentExtras.add(extra);
                        } else {
                          _currentExtras.removeWhere((e) => e.id == extra.id);
                        }
                      });
                    },
                    backgroundColor: colors.background,
                    selectedColor: colors.warningContainer,
                    checkmarkColor: colors.warning,
                    labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? colors.warning : colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                    side: BorderSide(color: isSelected ? colors.warning : colors.divider),
                  );
                }).toList(),
              ),
            ],

            // --- NOTE ---
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.labelNotesTitle, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                  filled: true,
                  hintText: AppLocalizations.of(context)!.fieldNotesPlaceholder,
                  fillColor: colors.background
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            widget.onSave(
              _qtyToModify,
              _noteController.text,
              _selectedCourse,
              _currentExtras,
            );
          },
          child: Text(AppLocalizations.of(context)!.dialogSave, style: TextStyle(fontSize: 14)),
        )
      ],
    );
  }
}
