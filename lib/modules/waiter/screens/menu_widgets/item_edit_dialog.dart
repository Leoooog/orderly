import 'package:flutter/material.dart';
import '../../../../config/themes.dart';
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
    final int maxQty = widget.cartItem.qty;

    return AlertDialog(
      backgroundColor: AppColors.cWhite,
      surfaceTintColor: AppColors.cWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Modifica", style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
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
                "Stai modificando: ${widget.cartItem.name}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.cIndigo600)
            ),
            const SizedBox(height: 16),

            // --- SELETTORE QUANTITÀ (Solo se qty > 1) ---
            if (maxQty > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quanti piatti vuoi modificare?", style: TextStyle(fontSize: 12, color: AppColors.cSlate500, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: _qtyToModify > 1 ? AppColors.cIndigo600 : AppColors.cSlate300),
                          onPressed: _qtyToModify > 1 ? () => setState(() => _qtyToModify--) : null
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.cSlate100, borderRadius: BorderRadius.circular(8)),
                        child: Text("$_qtyToModify / $maxQty", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cSlate900)),
                      ),
                      IconButton(
                          icon: Icon(Icons.add_circle_outline, color: _qtyToModify < maxQty ? AppColors.cIndigo600 : AppColors.cSlate300),
                          onPressed: _qtyToModify < maxQty ? () => setState(() => _qtyToModify++) : null
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // --- SCELTA PORTATA ---
            const Text("Sposta in:", style: TextStyle(fontSize: 12, color: AppColors.cSlate500, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Course.values.map((course) {
                final isSel = _selectedCourse == course;
                return ChoiceChip(
                  label: Text(course.label, style: TextStyle(fontSize: 12, color: isSel ? AppColors.cWhite : AppColors.cSlate800)),
                  selected: isSel,
                  selectedColor: AppColors.cIndigo600,
                  backgroundColor: AppColors.cSlate100,
                  side: BorderSide.none,
                  onSelected: (v) => setState(() => _selectedCourse = course),
                );
              }).toList(),
            ),

            // --- SCELTA EXTRA ---
            if (widget.menuItem.availableExtras.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("Aggiunte:", style: TextStyle(fontSize: 12, color: AppColors.cSlate500, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.menuItem.availableExtras.map((extra) {
                  final isSelected = _currentExtras.any((e) => e.id == extra.id);
                  return FilterChip(
                    label: Text("${extra.name} (+€${extra.price.toStringAsFixed(2)})"),
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
                    backgroundColor: AppColors.cSlate50,
                    selectedColor: AppColors.cAmber100,
                    checkmarkColor: AppColors.cAmber700,
                    labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.cAmber700 : AppColors.cSlate800,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                    side: BorderSide(color: isSelected ? AppColors.cAmber700 : AppColors.cSlate200),
                  );
                }).toList(),
              ),
            ],

            // --- NOTE ---
            const SizedBox(height: 16),
            const Text("Note Cucina:", style: TextStyle(fontSize: 12, color: AppColors.cSlate500, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                  hintText: "Es. No cipolla...",
                  filled: true,
                  fillColor: AppColors.cSlate50
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cIndigo600,
            foregroundColor: AppColors.cWhite,
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
          child: const Text("Salva Modifiche"),
        )
      ],
    );
  }
}