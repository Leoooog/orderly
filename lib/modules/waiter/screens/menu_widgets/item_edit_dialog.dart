import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/local/cart_entry.dart';
import 'package:orderly/l10n/app_localizations.dart';
import '../../../../config/orderly_colors.dart';
import '../../../../data/models/menu/course.dart';
import '../../../../data/models/menu/extra.dart';
import '../../providers/menu_provider.dart';

class ItemEditDialog extends ConsumerStatefulWidget {
  final CartEntry cartEntry;
  // Callback updated with qty
  final Function(int qty, String note, Course course, List<Extra> extras) onSave;

  const ItemEditDialog({
    super.key,
    required this.cartEntry,
    required this.onSave,
  });

  @override
  ConsumerState<ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends ConsumerState<ItemEditDialog> {
  late TextEditingController _noteController;
  late Course _selectedCourse;
  late List<Extra> _currentExtras;
  late int _qtyToModify;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.cartEntry.notes);
    _selectedCourse = widget.cartEntry.course;
    _currentExtras = List.from(widget.cartEntry.selectedExtras);
    // By default, if we are editing, we start by modifying 1 unit (for the split)
    // or the total quantity if it is 1.
    _qtyToModify = 1;
    // If you prefer to select ALL available by default:
    // _qtyToModify = widget.cartItem.quantity;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allCourses = ref.watch(coursesProvider);
    final int maxQty = widget.cartEntry.quantity;

    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context)!.labelEdit,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          IconButton(
            icon: const Icon(Icons.close, size: 18.0),
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
                AppLocalizations.of(context)!
                    .cartEditingItem(widget.cartEntry.item.name),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    color: colors.primary)),
            const SizedBox(height: 16.0),

            // --- QUANTITY SELECTOR (Only if qty > 1) ---
            if (maxQty > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.cartEditingQuantity,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: _qtyToModify > 1
                                  ? colors.primary
                                  : colors.textTertiary,
                              size: 20.0),
                          onPressed: _qtyToModify > 1
                              ? () => setState(() => _qtyToModify--)
                              : null),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Text("$_qtyToModify / $maxQty",
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary)),
                      ),
                      IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: _qtyToModify < maxQty
                                  ? colors.primary
                                  : colors.textTertiary,
                              size: 20.0),
                          onPressed: _qtyToModify < maxQty
                              ? () => setState(() => _qtyToModify++)
                              : null),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],

            // --- COURSE SELECTION ---
            Text(AppLocalizations.of(context)!.dialogMoveToCourse,
                style: TextStyle(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: allCourses.map((course) {
                final isSel = _selectedCourse.id == course.id;
                return ChoiceChip(
                  label: Text(course.name,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: isSel ? colors.onPrimary : colors.textPrimary)),
                  selected: isSel,
                  selectedColor: colors.primary,
                  backgroundColor: colors.background,
                  side: BorderSide.none,
                  onSelected: (v) => setState(() => _selectedCourse = course),
                );
              }).toList(),
            ),

            // --- EXTRA SELECTION ---
            if (widget.cartEntry.item.allowedExtras.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(AppLocalizations.of(context)!.labelExtras,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.cartEntry.item.allowedExtras.map((extra) {
                  final isSelected =
                      _currentExtras.any((e) => e.id == extra.id);
                  return FilterChip(
                    label: Text(
                        "${extra.name} (+€${extra.price.toStringAsFixed(2)})",
                        style: const TextStyle(fontSize: 12.0)),
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
                        fontSize: 12.0,
                        color: isSelected ? colors.warning : colors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal),
                    side: BorderSide(
                        color:
                            isSelected ? colors.warning : colors.divider),
                  );
                }).toList(),
              ),
            ],

            // --- NOTES ---
            const SizedBox(height: 16.0),
            Text(AppLocalizations.of(context)!.labelNotesTitle,
                style: TextStyle(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                  filled: true,
                  hintText:
                      AppLocalizations.of(context)!.fieldNotesPlaceholder,
                  fillColor: colors.background),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          onPressed: () {
            widget.onSave(
              _qtyToModify,
              _noteController.text,
              _selectedCourse,
              _currentExtras,
            );
          },
          child: Text(AppLocalizations.of(context)!.dialogSave,
              style: const TextStyle(fontSize: 14.0)),
        )
      ],
    );
  }
}