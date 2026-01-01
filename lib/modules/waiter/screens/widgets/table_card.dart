import 'package:flutter/material.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';
import '../../../../data/models/table_item.dart';

class TableCard extends StatefulWidget {
  final TableSession table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<TableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _bellScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bellScaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.table.status == TableStatus.ready) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.table.status == TableStatus.ready) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool isOccupied = widget.table.status != TableStatus.free;
    final bool isReady = widget.table.status == TableStatus.ready;

    // DEFINIZIONE COLORI E STILI
    Color cardBgColor = colors.surface;
    Color borderColor = colors.divider;
    Color contentColor = colors.textPrimary;
    Color accentColor = colors.textSecondary;

    Widget? statusIcon;
    String statusLabel = "";

    switch (widget.table.status) {
      case TableStatus.seated:
        cardBgColor = colors.dangerContainer;
        borderColor = colors.danger;
        contentColor = colors.danger;
        accentColor = colors.danger;
        statusIcon = Icon(Icons.hourglass_empty, size: 10, color: colors.danger);
        statusLabel = AppLocalizations.of(context)!.tableStatusSeated;
        break;
      case TableStatus.ordered:
        cardBgColor = colors.warningContainer;
        borderColor = colors.warning;
        contentColor = colors.warning;
        accentColor = colors.warning;
        statusIcon = Icon(Icons.sticky_note_2, size: 10, color: colors.warning);
        statusLabel = AppLocalizations.of(context)!.tableStatusOrdered;
        break;
      case TableStatus.ready:
        cardBgColor = colors.surface;
        borderColor = colors.success;
        contentColor = colors.textPrimary;
        accentColor = colors.success;
        statusIcon = Icon(Icons.notifications_active, size: 10, color: colors.success);
        statusLabel = AppLocalizations.of(context)!.tableStatusReady;
        break;
      case TableStatus.eating:
        cardBgColor = colors.surface;
        borderColor = colors.infoContainer;
        contentColor = colors.textPrimary;
        accentColor = colors.primary;
        statusIcon = Icon(Icons.restaurant, size: 10, color: colors.primary);
        statusLabel = AppLocalizations.of(context)!.tableStatusEating;
        break;
      case TableStatus.free:
        cardBgColor = colors.surface;
        borderColor = colors.successContainer;
        contentColor = colors.textTertiary;
        accentColor = colors.success;
        break;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (BuildContext context, Widget? child) {
        double scale = 1.0;
        if (isReady) {
          scale = 1.0 + 0.05 * _pulseController.value;
        }
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2.0,
        shadowColor: colors.shadow.withValues(alpha: 0.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isReady ? 3 : 2,
              ),
            ),
            child: Stack(
              children: [
                // CAMPANELLA NOTIFICA (In alto a destra)
                if (isReady)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ScaleTransition(
                      scale: _bellScaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: colors.success, shape: BoxShape.circle),
                        child: Icon(Icons.notifications_active,
                            color: colors.textInverse, size: 12),
                      ),
                    ),
                  ),

                // PUNTINO DI STATO (In alto a destra se non Ready)
                if (isOccupied && !isReady)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle),
                    ),
                  ),

                // CONTENUTO CENTRALE RESPONSIVE
                Padding(
                  padding: const EdgeInsets.all(8.0), // Padding interno generale
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // NOME TAVOLO (Scalabile)
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.table.name,
                            style: TextStyle(
                                fontSize: 24, // Dimensione base
                                fontWeight: FontWeight.bold,
                                color: isOccupied
                                    ? contentColor
                                    : colors.textPrimary),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // INFO STATO (Scalabile)
                      if (isOccupied) ...[
                        Flexible(
                          flex: 1,
                          child: Column(
                            mainAxisSize:
                            MainAxisSize.min, // Occupa solo spazio necessario
                            children: [
                              // BADGE STATO
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (statusIcon != null) statusIcon,
                                    if (statusIcon != null)
                                      const SizedBox(width: 4),
                                    Flexible(
                                      // Permette al testo di restringersi se necessario
                                      child: Text(
                                        statusLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize:
                                            9, // Leggermente più grande per leggibilità
                                            fontWeight: FontWeight.w900,
                                            color: accentColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // COPERTI
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people,
                                      size: 12,
                                      color: contentColor.withValues(alpha: 0.7)),
                                  const SizedBox(width: 4),
                                  Text("${widget.table.guests}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: contentColor,
                                          fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else
                      // BADGE FREE
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: colors.successContainer,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                  AppLocalizations.of(context)!.tableStatusFree,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colors.success)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}