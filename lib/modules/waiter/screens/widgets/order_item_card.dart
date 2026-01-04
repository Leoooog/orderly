import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/config/orderly_colors.dart';
import 'package:orderly/data/models/enums/order_item_status.dart';
import 'package:orderly/data/models/session/order_item.dart';
import 'package:orderly/l10n/app_localizations.dart';

class OrderItemCard extends ConsumerWidget {
  final OrderItem item;
  final bool isLast;
  final bool isFirst;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const OrderItemCard({
    super.key,
    required this.item,
    this.isLast = false,
    this.isFirst = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    // --- Logica Colori e Stato (Estratta da HistoryTab) ---
    Color bgColor = colors.surface;
    Color iconColor = colors.textTertiary;
    IconData icon = Icons.circle_outlined;
    String statusLabel = "";
    bool showMarkServedButton = false;
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
        showMarkServedButton = true;
        break;
      case OrderItemStatus.served:
        bgColor = colors.surface;
        iconColor = colors.textTertiary;
        icon = Icons.check;
        statusLabel = AppLocalizations.of(context)!.itemStatusServed;
        opacity = 0.6; // Leggermente più opaco per indicare completato
        break;
      case OrderItemStatus.unknown:
        bgColor = colors.surface;
        iconColor = colors.textTertiary;
        icon = Icons.help_outline;
        statusLabel = AppLocalizations.of(context)!.itemStatusUnknown;
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
          onTap: onTap,
          onLongPress: onLongPress,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RIGA SUPERIORE: Qta, Nome, Stato/Action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Quantità
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: iconColor.withValues(alpha: 0.3))),
                      child: Text("${item.quantity}x",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 12),

                    // Nome Piatto
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(item.menuItemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: colors.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Icona Stato o Bottone Azione
                    if (showMarkServedButton)
                      GestureDetector(
                        onTap: onTap, // Gestito specificamente nel parent
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: colors.success,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          colors.success.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ]),
                            child: Text(
                                AppLocalizations.of(context)!.btnMarkServed,
                                style: TextStyle(
                                    color: colors.textInverse,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5))),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(icon, size: 20, color: iconColor),
                          const SizedBox(height: 2),
                          Text(statusLabel,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: iconColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                  ],
                ),

                // SECTION: EXTRAS, REMOVED, NOTES
                if (item.selectedExtras.isNotEmpty ||
                    item.removedIngredients.isNotEmpty ||
                    (item.notes != null && item.notes!.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(left: 44, top: 8),
                    // Indentazione allineata col testo
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag: Extra e Rimozioni
                        if (item.selectedExtras.isNotEmpty ||
                            item.removedIngredients.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              // Extras (Verdi)
                              ...item.selectedExtras.map((e) =>
                                  _buildModificationTag(
                                      context,
                                      "+ ${e.name}",
                                      colors.successContainer
                                          .withValues(alpha: 0.5),
                                      colors.success)),

                              // Rimozioni (Rossi)
                              ...item.removedIngredients.map((i) =>
                                  _buildModificationTag(
                                      context,
                                      "No ${i.name}",
                                      colors.dangerContainer
                                          .withValues(alpha: 0.3),
                                      colors.danger,
                                      isRemoved: true)),
                            ],
                          ),

                        // Note (Gialle)
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.comment,
                                    size: 12, color: colors.warning),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(item.notes!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: colors.warning,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Costruisce i piccoli tag visuali (stile ProductCard)
  Widget _buildModificationTag(
      BuildContext context, String text, Color bg, Color textColor,
      {bool isRemoved = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          decoration: isRemoved ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
