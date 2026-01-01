import 'package:flutter/material.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';
import '../../../../data/models/order_item.dart';
import '../../../../data/models/course.dart';
import '../../../../data/models/extra.dart';
import '../../../../data/models/menu_item.dart';

class ItemEditDialog extends StatefulWidget {
  final OrderItem cartItem;
  final MenuItem menuItem;
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
    _qtyToModify = 1;
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
      // scrollable: true è FONDAMENTALE per gestire la tastiera e schermi piccoli
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              AppLocalizations.of(context)!.labelEdit,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: ConstrainedBox(
        // RESPONSIVE: Limita la larghezza su tablet/PC.
        // Su telefono occupa lo spazio disponibile (fino a 500).
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo Piatto (con Flexible per evitare overflow testo)
            Flexible(
              child: Text(
                  AppLocalizations.of(context)!.cartEditingItem(widget.menuItem.name),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.primary)
              ),
            ),
            const SizedBox(height: 16),

            // --- SELETTORE QUANTITÀ (Solo se qty > 1) ---
            if (maxQty > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                          AppLocalizations.of(context)!.cartEditingQuantity,
                          style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)
                      )
                  ),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: _qtyToModify > 1 ? colors.primary : colors.textTertiary, size: 24),
                          onPressed: _qtyToModify > 1 ? () => setState(() => _qtyToModify--) : null
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                            "$_qtyToModify / $maxQty",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.add_circle_outline, color: _qtyToModify < maxQty ? colors.primary : colors.textTertiary, size: 24),
                          onPressed: _qtyToModify < maxQty ? () => setState(() => _qtyToModify++) : null
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // --- SCELTA PORTATA ---
            Text(AppLocalizations.of(context)!.dialogMoveToCourse, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8, // Importante per andare a capo bene
              children: Course.values.map((course) {
                final isSel = _selectedCourse == course;
                return ChoiceChip(
                  label: Text(course.label, style: TextStyle(fontSize: 12, color: isSel ? colors.onPrimary : colors.textPrimary)),
                  selected: isSel,
                  selectedColor: colors.primary,
                  backgroundColor: colors.background,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: (v) => setState(() => _selectedCourse = course),
                );
              }).toList(),
            ),

            // --- SCELTA EXTRA ---
            if (widget.menuItem.availableExtras.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.labelExtras, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.menuItem.availableExtras.map((extra) {
                  final isSelected = _currentExtras.any((e) => e.id == extra.id);
                  return FilterChip(
                    label: Text("${extra.name} (+€${extra.price.toStringAsFixed(2)})", style: const TextStyle(fontSize: 12)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isSelected ? colors.warning : colors.divider)
                    ),
                    labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? colors.warning : colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                  );
                }).toList(),
              ),
            ],

            // --- NOTE ---
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.labelNotesTitle, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3, // Aumentato leggermente per comodità
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  filled: true,
                  hintText: AppLocalizations.of(context)!.fieldNotesPlaceholder,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none
                  ),
                  contentPadding: const EdgeInsets.all(12)
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.dialogCancel, style: TextStyle(color: colors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            widget.onSave(
              _qtyToModify,
              _noteController.text,
              _selectedCourse,
              _currentExtras,
            );
          },
          child: Text(AppLocalizations.of(context)!.dialogSave, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}