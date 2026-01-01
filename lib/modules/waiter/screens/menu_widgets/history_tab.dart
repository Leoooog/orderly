import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/restaurant_settings.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';

import '../../../../data/models/table_item.dart';
import '../../../../data/models/order_item.dart';
import '../../../../data/models/course.dart';
import '../../../../data/models/extra.dart';
import '../../providers/tables_provider.dart';
import '../../providers/menu_provider.dart';

// Importa il nuovo widget
import 'item_edit_dialog.dart';

class HistoryTab extends ConsumerWidget {
  final TableSession table;

  const HistoryTab({super.key, required this.table});

  // --- LOGICA ---

  void _fireCourse(BuildContext context, WidgetRef ref, Course course) {
    ref.read(tablesProvider.notifier).fireCourse(table.id, course);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
        Text(AppLocalizations.of(context)!.msgCourseFired(course.label)),
        backgroundColor: context.colors.primary,
        duration: const Duration(seconds: 1)));
  }

  void _markServed(WidgetRef ref, OrderItem item) {
    ref.read(tablesProvider.notifier).markAsServed(table.id, item.internalId);
  }

  void _performVoid(BuildContext context, WidgetRef ref, OrderItem item, int qty,
      String reason, bool isRefunded) {
    ref
        .read(tablesProvider.notifier)
        .voidItem(table.id, item.internalId, qty, reason, isRefunded);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.msgVoidItem),
      backgroundColor: context.colors.warning,
    ));
  }

  void _performUpdate(BuildContext context, WidgetRef ref, OrderItem item,
      int qty, String note, Course course, List<Extra> extras) {
    ref.read(tablesProvider.notifier).updateOrderedItem(
        table.id, item.internalId, qty, note, course, extras);
    Navigator.pop(context); // Chiudi dialog
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.msgChangesSaved)));
  }

  // --- DIALOGHI ---

  void _showVoidsHistory(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final voids = ref.read(tablesProvider.notifier).getVoidsForTable(table.id);

    // Responsive Logic
    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 600 : double.infinity;
    // Altezza massima del foglio: 60% dello schermo
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Necessario per gestire i constraints custom
      backgroundColor: Colors.transparent, // TRUCCO: Sfondo trasparente per evitare full screen colorato
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Container(
          color: Colors.transparent, // Catch taps on the transparent area
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent taps inside the sheet from closing it
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: BoxDecoration(
                color: colors.surface, // Il colore va QUI
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Adatta l'altezza al contenuto
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                          AppLocalizations.of(context)!.labelVoidedList(table.name),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colors.danger)),
                    ),
                    const Divider(height: 1),
                    if (voids.isEmpty)
                      SizedBox(
                        height: 100,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!.labelNoVoidedItems,
                                style: TextStyle(
                                    color: colors.textTertiary, fontSize: 14))),
                      )
                    else
                    // Flexible permette alla lista di occupare MENO spazio se ha pochi elementi
                    // o di scrollare se ne ha troppi, fino al maxHeight definito sopra.
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: voids.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final v = voids[index];
                            return ListTile(
                              title: Text("${v.quantity}x ${v.itemName}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(
                                AppLocalizations.of(context)!.labelVoidReason(
                                    v.reason,
                                    v.timestamp.hour.toString(),
                                    v.timestamp.minute.toString().padLeft(2, '0'),
                                    v.isRefunded.toString(),
                                    v.statusWhenVoided.toString()),
                              ),
                              trailing: Text(
                                  v.isRefunded
                                      ? "-${v.totalVoidAmount.toCurrency()}"
                                      : "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: v.isRefunded
                                          ? colors.danger
                                          : colors.textTertiary,
                                      fontWeight: FontWeight.bold)),
                              isThreeLine: true,
                            );
                          },
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showItemOptions(BuildContext context, WidgetRef ref, OrderItem item) {
    final colors = context.colors;
    final bool canEdit = item.status == OrderItemStatus.pending;

    // Responsive Logic
    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 600 : double.infinity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // TRUCCO: Sfondo trasparente
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent taps inside the sheet from closing it
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: colors.surface, // Il colore va QUI
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              // ClipRRect assicura che i figli rispettino i bordi arrotondati
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SafeArea(
                  child: Material(
                    type: MaterialType.transparency, // Permette agli Ink di "salire"
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(item.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18))),
                        if (canEdit)
                          ListTile(
                            leading: Icon(Icons.edit, color: colors.primary),
                            title: Text(AppLocalizations.of(context)!.labelEdit),
                            subtitle: Text(
                                AppLocalizations.of(context)!.subtitleEditItemAction),
                            onTap: () {
                              Navigator.pop(ctx);
                              _showEditDialog(context, ref, item);
                            },
                          ),
                        ListTile(
                          leading: Icon(Icons.delete_forever, color: colors.danger),
                          title:
                          Text(AppLocalizations.of(context)!.titleVoidItemAction),
                          subtitle: Text(
                              AppLocalizations.of(context)!.subtitleVoidItemAction),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showVoidDialog(context, ref, item);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _showEditDialog(BuildContext context, WidgetRef ref, OrderItem item) {
    final menuItems = ref.read(menuProvider);
    final menuItem = menuItems.firstWhere((m) => m.id == item.id,
        orElse: () => menuItems[0]);

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

  void _showVoidDialog(BuildContext context, WidgetRef ref, OrderItem item) {
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
        final colors = context.colors;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: colors.surface,
            title: Text(AppLocalizations.of(context)!.titleVoidItem,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colors.danger)),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        AppLocalizations.of(context)!
                            .titleVoidItemDialog(item.name),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    if (item.qty > 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.labelVoidQuantity,
                              style: TextStyle(
                                  fontSize: 12, color: colors.textSecondary)),
                          Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: qtyToVoid > 1
                                          ? colors.primary
                                          : colors.divider),
                                  onPressed: qtyToVoid > 1
                                      ? () => setStateDialog(() => qtyToVoid--)
                                      : null),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: colors.background,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text("$qtyToVoid / ${item.qty}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary)),
                              ),
                              IconButton(
                                  icon: Icon(Icons.add_circle_outline,
                                      color: qtyToVoid < item.qty
                                          ? colors.primary
                                          : colors.divider),
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
                        Text(AppLocalizations.of(context)!.labelRefundOption,
                            style: TextStyle(
                                fontSize: 12, color: colors.textSecondary)),
                        Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: isRefunded,
                              activeThumbColor: colors.danger,
                              onChanged: (v) =>
                                  setStateDialog(() => isRefunded = v),
                            )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                        AppLocalizations.of(context)!
                            .labelVoidReasonPlaceholder,
                        style: TextStyle(
                            fontSize: 12, color: colors.textSecondary)),
                    Wrap(
                        spacing: 8,
                        children: reasons
                            .map((r) => ChoiceChip(
                          checkmarkColor: colors.textInverse,
                          label:
                          Text(r, style: const TextStyle(fontSize: 12)),
                          selected: selectedReason == r,
                          onSelected: (v) => setStateDialog(
                                  () => selectedReason = v ? r : ""),
                          selectedColor: colors.danger,
                          labelStyle: TextStyle(
                              color: selectedReason == r
                                  ? colors.textInverse
                                  : colors.textPrimary,
                              fontSize: 12),
                          side: BorderSide.none,
                          backgroundColor: colors.background,
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
                      decoration: InputDecoration(
                          hintText: "PIN (1234)",
                          counterText: "",
                          filled: true,
                          fillColor: colors.background),
                      onChanged: (v) => setStateDialog(() {}),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)!.dialogCancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: colors.danger,
                    foregroundColor: colors.textInverse),
                onPressed:
                (selectedReason.isNotEmpty && pinController.text == "1234")
                    ? () => _performVoid(context, ref, item, qtyToVoid,
                    selectedReason, isRefunded)
                    : null,
                child: Text(AppLocalizations.of(context)!.dialogConfirmVoid),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 700 : double.infinity;

    if (table.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: colors.divider),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.labelNoOrders,
                style: TextStyle(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            if (ref
                .read(tablesProvider.notifier)
                .getVoidsForTable(table.id)
                .isNotEmpty)
              TextButton(
                  onPressed: () => _showVoidsHistory(context, ref),
                  child: Text(AppLocalizations.of(context)!.labelViewVoided)),
          ],
        ),
      );
    }

    final Map<Course, List<OrderItem>> groupedOrders = {};
    for (var course in Course.values) {
      final items = table.orders.where((o) => o.course == course).toList();
      if (items.isNotEmpty) groupedOrders[course] = items;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton.icon(
                  onPressed: () => _showVoidsHistory(context, ref),
                  icon: Icon(Icons.history, size: 16, color: colors.danger),
                  label: Text(AppLocalizations.of(context)!.labelViewVoided,
                      style: TextStyle(
                          color: colors.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
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
        ),
      ),
    );
  }

  // _buildCourseSection, _buildSectionBadge, _buildHistoryItemRow restano uguali
  // ma per completezza li includo qui sotto:

  Widget _buildCourseSection(BuildContext context, WidgetRef ref, Course course,
      List<OrderItem> items) {
    final colors = context.colors;
    final bool hasPendingItems =
    items.any((i) => i.status == OrderItemStatus.pending);
    final bool hasReady = items.any((i) => i.status == OrderItemStatus.ready);
    final bool hasCooking = items.any((i) => i.status == OrderItemStatus.cooking);
    final bool isCompleted = items.every((i) => i.status == OrderItemStatus.served);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(course.label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                      letterSpacing: 1.2)),
            ),
            const SizedBox(width: 8),
            if (hasPendingItems)
              ElevatedButton.icon(
                onPressed: () => _fireCourse(context, ref, course),
                icon: const Icon(Icons.notifications_active, size: 16),
                label: Text(AppLocalizations.of(context)!.btnFireCourse,
                    style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (hasReady)
              _buildSectionBadge(
                  Icons.room_service,
                  AppLocalizations.of(context)!.badgeStatusReady,
                  colors.success,
                  colors.successContainer)
            else if (hasCooking)
                _buildSectionBadge(
                    Icons.local_fire_department,
                    AppLocalizations.of(context)!.badgeStatusCooking,
                    colors.warning,
                    colors.warningContainer)
              else if (isCompleted)
                  _buildSectionBadge(
                      Icons.check_circle,
                      AppLocalizations.of(context)!.badgeStatusCompleted,
                      colors.textTertiary,
                      colors.background)
                else
                  _buildSectionBadge(
                      Icons.hourglass_top,
                      AppLocalizations.of(context)!.badgeStatusInQueue,
                      colors.primary,
                      colors.infoSurfaceStrong)
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider)),
          child: Column(
            children: items.asMap().entries.map((entry) {
              return _buildHistoryItemRow(context, ref, entry.value,
                  isLast: entry.key == items.length - 1,
                  isFirst: entry.key == 0);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBadge(
      IconData icon, String label, Color textColor, Color bgColor) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
        BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItemRow(
      BuildContext context, WidgetRef ref, OrderItem item,
      {bool isLast = false, bool isFirst = false}) {
    final colors = context.colors;
    Color bgColor = colors.surface;
    Color iconColor = colors.textTertiary;
    IconData icon = Icons.circle_outlined;
    String statusLabel = "";
    bool isInteractive = false;
    double opacity = 1.0;

    switch (item.status) {
      case OrderItemStatus.pending:
        bgColor = colors.warningContainer;
        iconColor = colors.warning;
        icon = Icons.schedule;
        statusLabel = AppLocalizations.of(context)!.itemStatusPending;
        break;
      case OrderItemStatus.fired:
        bgColor = colors.infoSurfaceFaint;
        iconColor = colors.primary;
        icon = Icons.hourglass_top;
        statusLabel = AppLocalizations.of(context)!.itemStatusFired;
        break;
      case OrderItemStatus.cooking:
        bgColor = colors.infoSurfaceWeak;
        iconColor = colors.primary;
        icon = Icons.local_fire_department;
        statusLabel = AppLocalizations.of(context)!.itemStatusCooking;
        break;
      case OrderItemStatus.ready:
        bgColor = colors.successContainer;
        iconColor = colors.success;
        icon = Icons.room_service;
        statusLabel = AppLocalizations.of(context)!.itemStatusReady;
        isInteractive = true;
        break;
      case OrderItemStatus.served:
        bgColor = colors.surface;
        iconColor = colors.textTertiary;
        icon = Icons.check;
        statusLabel = AppLocalizations.of(context)!.itemStatusServed;
        opacity = 0.5;
        break;
    }

    final borderRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Opacity(
      opacity: opacity,
      child: Material(
        color: bgColor,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: isInteractive ? () => _markServed(ref, item) : null,
          onLongPress: () => _showItemOptions(context, ref, item),
          hoverColor: colors.hover,
          borderRadius: borderRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border(
                bottom: (item.status == OrderItemStatus.fired ||
                    item.status == OrderItemStatus.served) &&
                    !isLast
                    ? BorderSide(color: colors.divider)
                    : BorderSide.none,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border:
                      Border.all(color: iconColor.withValues(alpha: 0.3))),
                  child: Text("${item.qty}x",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                          fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary)),
                        if (item.selectedExtras.isNotEmpty)
                          Text(
                              item.selectedExtras
                                  .map((e) => "+ ${e.name}")
                                  .join(", "),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11, color: colors.textSecondary)),
                        if (item.notes.isNotEmpty)
                          Text(item.notes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: colors.warning,
                                  fontStyle: FontStyle.italic)),
                      ]),
                ),
                const SizedBox(width: 8),
                if (item.status == OrderItemStatus.ready)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: colors.success,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(AppLocalizations.of(context)!.btnMarkServed,
                          style: TextStyle(
                              color: colors.textInverse,
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
      ),
    );
  }

}