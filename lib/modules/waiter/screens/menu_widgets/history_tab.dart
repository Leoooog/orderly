import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/themes.dart';
import '../../../../data/models/table_item.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/course.dart';
import '../../providers/tables_provider.dart';

class HistoryTab extends ConsumerWidget {
  final TableItem table;

  const HistoryTab({super.key, required this.table});

  void _fireCourse(BuildContext context, WidgetRef ref, Course course) {
    ref.read(tablesProvider.notifier).fireCourse(table.id, course);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Richiesto 'Via' per ${course.label}"),
            backgroundColor: AppColors.cIndigo600,
            duration: const Duration(seconds: 1)
        )
    );
  }

  void _markServed(WidgetRef ref, CartItem item) {
    ref.read(tablesProvider.notifier).markAsServed(table.id, item.internalId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (table.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long, size: 64, color: AppColors.cSlate200),
            SizedBox(height: 16),
            Text("Nessun ordine inviato", style: TextStyle(color: AppColors.cSlate400, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final Map<Course, List<CartItem>> groupedOrders = {};
    for (var course in Course.values) {
      final items = table.orders.where((o) => o.course == course).toList();
      if (items.isNotEmpty) groupedOrders[course] = items;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var course in groupedOrders.keys) ...[
          _buildCourseSection(context, ref, course, groupedOrders[course]!),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCourseSection(BuildContext context, WidgetRef ref, Course course, List<CartItem> items) {
    // Se c'è almeno un piatto "pending", mostriamo il tasto "DAI IL VIA"
    final bool hasPendingItems = items.any((i) => i.status == ItemStatus.pending);
    // Se tutti i piatti sono "served", la portata è completata
    final bool isCompleted = items.every((i) => i.status == ItemStatus.served);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(course.label.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cSlate500, letterSpacing: 1.2)),

            if (hasPendingItems)
              ElevatedButton.icon(
                onPressed: () => _fireCourse(context, ref, course),
                icon: const Icon(Icons.notifications_active, size: 16),
                label: const Text("DAI IL VIA"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cIndigo600, foregroundColor: AppColors.cWhite, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (isCompleted)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.cSlate100, borderRadius: BorderRadius.circular(4)), child: Row(children: const [Icon(Icons.check_circle, size: 14, color: AppColors.cSlate400), SizedBox(width: 4), Text("COMPLETATO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cSlate400))]))
            else
            // Indicatore stato misto (es. In preparazione o Pronti)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.cEmerald100, borderRadius: BorderRadius.circular(4)), child: Row(children: const [Icon(Icons.restaurant, size: 14, color: AppColors.cEmerald500), SizedBox(width: 4), Text("IN CORSO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cEmerald500))]))
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.cWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cSlate200)),
          child: Column(
            children: items.asMap().entries.map((entry) {
              return Column(
                children: [
                  _buildHistoryItemRow(ref, entry.value),
                  if (entry.key != items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.cSlate100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItemRow(WidgetRef ref, CartItem item) {
    bool hasExtras = item.selectedExtras.isNotEmpty;

    // DEFINIZIONE STILI IN BASE ALLO STATO
    Color bgColor = AppColors.cWhite;
    Color iconColor = AppColors.cSlate400;
    IconData icon = Icons.circle_outlined;
    bool isInteractive = false;
    double opacity = 1.0;

    switch (item.status) {
      case ItemStatus.pending:
        bgColor = AppColors.cOrange50;
        iconColor = AppColors.cOrange200;
        icon = Icons.schedule;
        break;
      case ItemStatus.fired:
        bgColor = AppColors.cIndigo100.withOpacity(0.2);
        iconColor = AppColors.cIndigo600;
        icon = Icons.soup_kitchen;
        break;
      case ItemStatus.ready:
        bgColor = AppColors.cEmerald100; // Verde forte per attirare attenzione
        iconColor = AppColors.cEmerald500;
        icon = Icons.room_service; // Campanella/Servizio
        isInteractive = true; // Cliccabile per servire
        break;
      case ItemStatus.served:
        bgColor = AppColors.cWhite;
        iconColor = AppColors.cSlate300;
        icon = Icons.check;
        opacity = 0.5; // Sbiadito
        break;
    }

    return InkWell(
      onTap: isInteractive ? () => _markServed(ref, item) : null,
      child: Opacity(
        opacity: opacity,
        child: Container(
          color: bgColor, // Sfondo colorato per stato
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32, height: 32, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.cWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: iconColor.withOpacity(0.3))),
                child: Text("${item.qty}x", style: TextStyle(fontWeight: FontWeight.bold, color: iconColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.cSlate900)),
                  if (item.selectedExtras.isNotEmpty) Text(item.selectedExtras.map((e) => "+ ${e.name}").join(", "), style: const TextStyle(fontSize: 11, color: AppColors.cSlate500)),
                  if (item.notes.isNotEmpty) Text(item.notes, style: const TextStyle(fontSize: 11, color: AppColors.cAmber700, fontStyle: FontStyle.italic)),
                ]),
              ),
              // Icona di stato o Azione
              if (item.status == ItemStatus.ready)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.cEmerald500, borderRadius: BorderRadius.circular(12)),
                  child: const Text("SERVI", style: TextStyle(color: AppColors.cWhite, fontWeight: FontWeight.bold, fontSize: 10)),
                )
              else
                Icon(icon, size: 20, color: iconColor)
            ],
          ),
        ),
      ),
    );
  }
}