import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/themes.dart';
import '../../../../data/models/table_item.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/course.dart';
import '../../../../data/models/extra.dart';
import '../../providers/tables_provider.dart';
import '../../providers/menu_provider.dart';

// Importa il nuovo widget
import 'item_edit_dialog.dart';

class HistoryTab extends ConsumerWidget {
  final TableItem table;

  const HistoryTab({super.key, required this.table});

  // --- LOGICA ---

  void _fireCourse(BuildContext context, WidgetRef ref, Course course) {
    ref.read(tablesProvider.notifier).fireCourse(table.id, course);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Richiesto 'Via' per ${course.label}"),
        backgroundColor: AppColors.cIndigo600,
        duration: const Duration(seconds: 1)));
  }

  void _markServed(WidgetRef ref, CartItem item) {
    ref.read(tablesProvider.notifier).markAsServed(table.id, item.internalId);
  }

  void _performVoid(BuildContext context, WidgetRef ref, CartItem item, int qty,
      String reason, bool isRefunded) {
    ref
        .read(tablesProvider.notifier)
        .voidItem(table.id, item.internalId, qty, reason, isRefunded);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Piatto stornato correttamente"),
      backgroundColor: AppColors.cOrange700,
    ));
  }

  void _performUpdate(BuildContext context, WidgetRef ref, CartItem item,
      int qty, String note, Course course, List<Extra> extras) {
    ref.read(tablesProvider.notifier).updateOrderedItem(
        table.id, item.internalId, qty, note, course, extras);
    Navigator.pop(context); // Chiudi dialog
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Modifica salvata")));
  }

  // --- DIALOGHI ---

  void _showVoidsHistory(BuildContext context, WidgetRef ref) {
    final voids = ref.read(tablesProvider.notifier).getVoidsForTable(table.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cWhite,
      builder: (ctx) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Storico Storni (${table.name})",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.cRose500)),
            ),
            const Divider(height: 1),
            if (voids.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text("Nessuno storno registrato",
                          style: TextStyle(color: AppColors.cSlate400))))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: voids.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final v = voids[index];
                    return ListTile(
                      title: Text("${v.quantity}x ${v.itemName}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Motivo: ${v.reason}\n${v.timestamp.hour}:${v.timestamp.minute.toString().padLeft(2, '0')}"),
                      trailing: Text(
                          "-€ ${v.totalVoidAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: AppColors.cRose500,
                              fontWeight: FontWeight.bold)),
                      isThreeLine: true,
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, CartItem item) {
    // Recupera menu per gli extra disponibili
    final menuItems = ref.read(menuProvider);
    final menuItem = menuItems.firstWhere((m) => m.id == item.id,
        orElse: () => menuItems[0]);

    // Apri il Dialog custom che gestisce internamente la quantità
    showDialog(
      context: context,
      builder: (ctx) => ItemEditDialog(
        cartItem: item,
        menuItem: menuItem,
        onSave: (qty, note, course, extras) {
          _performUpdate(context, ref, item, qty, note, course, extras);
        },
      ),
    );
  }

  void _showVoidDialog(BuildContext context, WidgetRef ref, CartItem item) {
    int qtyToVoid = 1;
    String selectedReason = "";
    bool isRefunded = true;
    final TextEditingController pinController = TextEditingController();
    final List<String> reasons = [
      "Errore inserimento",
      "Cliente cambiato idea",
      "Piatto non conforme",
      "Altro"
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.cWhite,
            title: const Text("Storno Piatto",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.cRose500)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Elimina: ${item.name}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (item.qty > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Quantità da stornare:",
                            style: TextStyle(
                                fontSize: 12, color: AppColors.cSlate500)),
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: qtyToVoid > 1
                                        ? AppColors.cIndigo600
                                        : AppColors.cSlate300),
                                onPressed: qtyToVoid > 1
                                    ? () => setStateDialog(() => qtyToVoid--)
                                    : null),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: AppColors.cSlate100,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text("$qtyToVoid / ${item.qty}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.cSlate900)),
                            ),
                            IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: qtyToVoid < item.qty
                                        ? AppColors.cIndigo600
                                        : AppColors.cSlate300),
                                onPressed: qtyToVoid < item.qty
                                    ? () => setStateDialog(() => qtyToVoid++)
                                    : null),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rimborsare l'importo?",
                          style: TextStyle(
                              fontSize: 12, color: AppColors.cSlate500)),
                      Transform.scale(
                          scale: 0.8, // Riduci la dimensione dello switch
                          child: Switch(
                            value: isRefunded,
                            activeThumbColor: AppColors.cRose500,
                            onChanged: (v) =>
                                setStateDialog(() => isRefunded = v),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Motivazione:",
                      style:
                          TextStyle(fontSize: 12, color: AppColors.cSlate500)),
                  Wrap(
                      spacing: 8,
                      children: reasons
                          .map((r) => ChoiceChip(
                                label: Text(r),
                                selected: selectedReason == r,
                                onSelected: (v) => setStateDialog(
                                    () => selectedReason = v ? r : ""),
                                selectedColor: AppColors.cRose500,
                                labelStyle: TextStyle(
                                    color: selectedReason == r
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12),
                                side: BorderSide.none,
                                backgroundColor: AppColors.cSlate50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ))
                          .toList()),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                        hintText: "PIN (1234)",
                        counterText: "",
                        filled: true,
                        fillColor: AppColors.cSlate50),
                    onChanged: (v) => setStateDialog(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annulla")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cRose500,
                    foregroundColor: Colors.white),
                onPressed:
                    (selectedReason.isNotEmpty && pinController.text == "1234")
                        ? () => _performVoid(context, ref, item, qtyToVoid,
                            selectedReason, isRefunded)
                        : null,
                child: const Text("CONFERMA"),
              )
            ],
          );
        });
      },
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref, CartItem item) {
    final bool canEdit = item.status == ItemStatus.pending;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18))),
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.cIndigo600),
                title: const Text("Modifica"),
                subtitle: const Text("Cambia note o varianti"),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditDialog(context, ref, item);
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever, color: AppColors.cRose500),
              title: const Text("Storno / Elimina"),
              subtitle: const Text("Rimuovi piatto dall'ordine"),
              onTap: () {
                Navigator.pop(ctx);
                _showVoidDialog(context, ref, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (table.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long,
                size: 64, color: AppColors.cSlate200),
            const SizedBox(height: 16),
            const Text("Nessun ordine inviato",
                style: TextStyle(
                    color: AppColors.cSlate400, fontWeight: FontWeight.bold)),
            if (ref
                .read(tablesProvider.notifier)
                .getVoidsForTable(table.id)
                .isNotEmpty)
              TextButton(
                  onPressed: () => _showVoidsHistory(context, ref),
                  child: const Text("Vedi Storni"))
          ],
        ),
      );
    }

    final Map<Course, List<CartItem>> groupedOrders = {};
    for (var course in Course.values) {
      final items = table.orders.where((o) => o.course == course).toList();
      if (items.isNotEmpty) groupedOrders[course] = items;
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: TextButton.icon(
              onPressed: () => _showVoidsHistory(context, ref),
              icon: const Icon(Icons.history,
                  size: 16, color: AppColors.cRose500),
              label: const Text("Log Storni",
                  style: TextStyle(
                      color: AppColors.cRose500, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var course in groupedOrders.keys) ...[
                _buildCourseSection(
                    context, ref, course, groupedOrders[course]!),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSection(BuildContext context, WidgetRef ref, Course course,
      List<CartItem> items) {
    final bool hasPendingItems =
        items.any((i) => i.status == ItemStatus.pending);
    final bool hasReady = items.any((i) => i.status == ItemStatus.ready);
    final bool hasCooking = items.any((i) => i.status == ItemStatus.cooking);
    final bool isCompleted = items.every((i) => i.status == ItemStatus.served);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(course.label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cSlate500,
                    letterSpacing: 1.2)),
            if (hasPendingItems)
              ElevatedButton.icon(
                onPressed: () => _fireCourse(context, ref, course),
                icon: const Icon(Icons.notifications_active, size: 16),
                label: const Text("DAI IL VIA"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cIndigo600,
                    foregroundColor: AppColors.cWhite,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (hasReady)
              _buildSectionBadge(Icons.room_service, "PIATTI PRONTI",
                  AppColors.cEmerald500, AppColors.cEmerald100)
            else if (hasCooking)
              _buildSectionBadge(Icons.local_fire_department, "IN PREPARAZIONE",
                  AppColors.cOrange700, AppColors.cOrange50)
            else if (isCompleted)
              _buildSectionBadge(Icons.check_circle, "COMPLETATO",
                  AppColors.cSlate400, AppColors.cSlate100)
            else
              _buildSectionBadge(
                  Icons.hourglass_top,
                  "IN CODA",
                  AppColors.cIndigo600,
                  AppColors.cIndigo100.withValues(alpha: 0.5))
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: AppColors.cWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cSlate200)),
          child: Column(
            children: items.asMap().entries.map((entry) {
              return _buildHistoryItemRow(context, ref, entry.value,
                  isLast: entry.key == items.length - 1, isFirst: entry.key == 0);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBadge(
      IconData icon, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildHistoryItemRow(
      BuildContext context, WidgetRef ref, CartItem item, {bool isLast = false, bool isFirst = false}) {
    Color bgColor = AppColors.cWhite;
    Color iconColor = AppColors.cSlate400;
    IconData icon = Icons.circle_outlined;
    String statusLabel = "";
    bool isInteractive = false;
    double opacity = 1.0;

    switch (item.status) {
      case ItemStatus.pending:
        bgColor = AppColors.cOrange50;
        iconColor = AppColors.cOrange700;
        icon = Icons.schedule;
        statusLabel = "In attesa";
        break;
      case ItemStatus.fired:
        bgColor = AppColors.cIndigo100.withValues(alpha: 0.1);
        iconColor = AppColors.cIndigo600;
        icon = Icons.hourglass_top;
        statusLabel = "Inviato";
        break;
      case ItemStatus.cooking:
        bgColor = AppColors.cIndigo100.withValues(alpha: 0.25);
        iconColor = AppColors.cIndigo600;
        icon = Icons.local_fire_department;
        statusLabel = "In preparazione";
        break;
      case ItemStatus.ready:
        bgColor = AppColors.cEmerald100;
        iconColor = AppColors.cEmerald500;
        icon = Icons.room_service;
        statusLabel = "Pronto";
        isInteractive = true;
        break;
      case ItemStatus.served:
        bgColor = AppColors.cWhite;
        iconColor = AppColors.cSlate400;
        icon = Icons.check;
        statusLabel = "Servito";
        opacity = 0.5;
        break;
    }

    return InkWell(
      onTap: isInteractive ? () => _markServed(ref, item) : null,
      onLongPress: () => _showItemOptions(context, ref, item),
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(12) : Radius.zero,
              bottom: isLast ? const Radius.circular(12) : Radius.zero,
            ),
            border: Border(
              bottom: (item.status == ItemStatus.fired || item.status == ItemStatus.served) && !isLast
                  ? BorderSide(color: AppColors.cSlate200)
                  : BorderSide.none,
            ),
            color: bgColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.cWhite,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: iconColor.withValues(alpha: 0.3))),
                child: Text("${item.qty}x",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: iconColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.cSlate900)),
                      if (item.selectedExtras.isNotEmpty)
                        Text(
                            item.selectedExtras
                                .map((e) => "+ ${e.name}")
                                .join(", "),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.cSlate500)),
                      if (item.notes.isNotEmpty)
                        Text(item.notes,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.cAmber700,
                                fontStyle: FontStyle.italic)),
                    ]),
              ),
              if (item.status == ItemStatus.ready)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.cEmerald500,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text("SERVI",
                        style: TextStyle(
                            color: AppColors.cWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5)))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(icon, size: 18, color: iconColor),
                    const SizedBox(height: 2),
                    Text(statusLabel,
                        style: TextStyle(
                            fontSize: 8,
                            color: iconColor,
                            fontWeight: FontWeight.bold)),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
