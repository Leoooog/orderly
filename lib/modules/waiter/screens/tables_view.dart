import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';
import '../../../shared/widgets/payment_method_button.dart';
import '../providers/tables_provider.dart';
import '../providers/auth_provider.dart';
import 'bill_screen.dart';

class TablesView extends ConsumerStatefulWidget {
  const TablesView({super.key});

  @override
  ConsumerState<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends ConsumerState<TablesView> {
  // --- LOGICA INTERNA ---

  void _performMove(TableItem source, TableItem target) {
    ref.read(tablesProvider.notifier).moveTable(source.id, target.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tavolo spostato con successo")));
  }

  void _performMerge(TableItem source, TableItem target) {
    ref.read(tablesProvider.notifier).mergeTable(source.id, target.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tavoli uniti con successo")));
  }

  void _performPayment(TableItem table, List<CartItem> paidItems) {
    ref.read(tablesProvider.notifier).processPayment(table.id, paidItems);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: AppColors.cEmerald500,
      content: Text("Pagamento registrato"),
      duration: Duration(seconds: 2),
    ));
  }

  void _performOccupy(TableItem table, int guests) {
    ref.read(tablesProvider.notifier).occupyTable(table.id, guests);
    Navigator.pop(context);
    context.push('/menu/${table.id}');
  }

  void _performLogout() {
    ref.read(authProvider.notifier).logout();
  }

  // --- GESTORI UI ---

  void _handleTableTap(TableItem table) {
    if (table.status == TableStatus.free) {
      _showGuestsDialog(table);
    } else {
      context.push('/menu/${table.id}');
    }
  }

  void _handleTableLongPress(TableItem table) {
    if (table.status == TableStatus.free) return;

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
              padding: const EdgeInsets.all(16.0),
              child: Text("Azioni ${table.name}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.cSlate800)),
            ),
            ListTile(
              leading:
              const Icon(Icons.compare_arrows, color: AppColors.cIndigo600),
              title: const Text("Sposta Tavolo"),
              subtitle: const Text("Trasferisci su un tavolo libero"),
              onTap: () {
                Navigator.pop(ctx);
                _showTableSelectionDialog(table, isMerge: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.merge_type, color: AppColors.cAmber700),
              title: const Text("Unisci Tavolo"),
              subtitle: const Text("Unisci a un tavolo occupato"),
              onTap: () {
                Navigator.pop(ctx);
                _showTableSelectionDialog(table, isMerge: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.cIndigo600),
              title: const Text("Incasso Rapido (Totale)"),
              subtitle: const Text("Paga tutto senza dividere"),
              onTap: () {
                Navigator.pop(ctx);
                _showPaymentDialog(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money,
                  color: AppColors.cEmerald500),
              title: const Text("Cassa / Divisione Conto"),
              subtitle: const Text("Gestisci pagamenti parziali"),
              onTap: () {
                Navigator.pop(ctx);
                _openSplitBillScreen(table);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGHI ---

  void _openSplitBillScreen(TableItem table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cSlate50,
      useRootNavigator: true,
      builder: (ctx) => BillScreen(
          table: table,
          onConfirmPayment: (paidItems) {
            _performPayment(table, paidItems);

            final updatedTable = ref
                .read(tablesProvider)
                .firstWhere((t) => t.id == table.id, orElse: () => table);

            if (updatedTable.status == TableStatus.free) {
              Navigator.pop(ctx);
            }
          }),
    );
  }

  void _showPaymentDialog(TableItem table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cWhite,
        surfaceTintColor: AppColors.cWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Text("Incasso ${table.name}",
                style: const TextStyle(fontSize: 16, color: AppColors.cSlate500)),
            const SizedBox(height: 8),
            const Text("Totale da incassare",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cSlate800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("€ ${table.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cIndigo600)),
            const SizedBox(height: 24),
            const Text("Seleziona metodo (Paga Tutto):",
                style: TextStyle(color: AppColors.cSlate500, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PaymentMethodButton(
                    icon: Icons.credit_card,
                    label: "Carta",
                    color: AppColors.cIndigo600,
                    onTap: () {
                      Navigator.pop(ctx);
                      _performPayment(table, table.orders);
                    }),
                PaymentMethodButton(
                    icon: Icons.money,
                    label: "Contanti",
                    color: AppColors.cEmerald500,
                    onTap: () {
                      Navigator.pop(ctx);
                      _performPayment(table, table.orders);
                    }),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla",
                style: TextStyle(color: AppColors.cSlate500)),
          ),
        ],
      ),
    );
  }

  void _showTableSelectionDialog(TableItem source, {required bool isMerge}) {
    final allTables = ref.read(tablesProvider);

    final candidates = allTables.where((t) {
      if (t.id == source.id) return false;
      return isMerge ? t.status != TableStatus.free : t.status == TableStatus.free;
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cWhite,
        title: Text(isMerge ? "Unisci a..." : "Sposta su..."),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: candidates.isEmpty
              ? const Center(child: Text("Nessun tavolo disponibile"))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final t = candidates[index];
              return InkWell(
                onTap: () {
                  if (isMerge) {
                    _performMerge(source, t);
                  } else {
                    _performMove(source, t);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cSlate100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cSlate300),
                  ),
                  alignment: Alignment.center,
                  child: Text(t.name,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
        ],
      ),
    );
  }

  void _showGuestsDialog(TableItem table) {
    int guests = 2;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.cWhite,
            surfaceTintColor: AppColors.cWhite,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Center(
                child: Column(
                  children: [
                    Text("Apertura ${table.name}",
                        style:
                        const TextStyle(fontSize: 16, color: AppColors.cSlate500)),
                    const SizedBox(height: 4),
                    const Text("Quanti Coperti?",
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Text("$guests",
                      style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cIndigo600)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (guests > 1) setStateDialog(() => guests--);
                      },
                      icon: const Icon(Icons.remove_circle_outline,
                          size: 32, color: AppColors.cSlate500),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      onPressed: () {
                        if (guests < 20) setStateDialog(() => guests++);
                      },
                      icon: const Icon(Icons.add_circle_outline,
                          size: 32, color: AppColors.cIndigo600),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Annulla",
                    style: TextStyle(color: AppColors.cSlate500)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cIndigo600,
                  foregroundColor: AppColors.cWhite,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _performOccupy(table, guests),
                child: const Text("Apri Tavolo",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesProvider);

    return Scaffold(
      backgroundColor: AppColors.cSlate50,
      appBar: AppBar(
        backgroundColor: AppColors.cWhite,
        elevation: 0,
        titleSpacing: 24,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Sala",
                style: TextStyle(
                    color: AppColors.cSlate800,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            Text("Mario R. • Turno Pranzo",
                style: TextStyle(color: AppColors.cSlate500, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings, color: AppColors.cSlate400),
              onPressed: () {
                context.push('/settings');
              }),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.cRose500),
            onPressed: _performLogout,
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.cSlate100, height: 1)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          return _TableCard(
            table: table,
            onTap: () => _handleTableTap(table),
            onLongPress: () => _handleTableLongPress(table),
          );
        },
      ),
    );
  }
}

class _TableCard extends StatefulWidget {
  final TableItem table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TableCard({
    required this.table,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.table.status == TableStatus.ready) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_TableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Gestione dinamica dell'animazione al cambio di stato
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
    final bool isOccupied = widget.table.status != TableStatus.free;

    // DEFINIZIONE COLORI E STILI IN BASE ALLO STATO
    Color cardBgColor = AppColors.cWhite;
    Color borderColor = AppColors.cSlate200;
    Color contentColor = AppColors.cSlate800;
    Color accentColor = AppColors.cSlate500;

    Widget? statusIcon;
    String statusLabel = "";

    switch (widget.table.status) {
      case TableStatus.seated:
        cardBgColor = AppColors.cRose50;
        borderColor = AppColors.cRose500;
        contentColor = AppColors.cRose500;
        accentColor = AppColors.cRose500;
        statusIcon = const Icon(Icons.hourglass_empty, size: 10, color: AppColors.cRose500);
        statusLabel = "ATTESA";
        break;
      case TableStatus.ordered:
        cardBgColor = AppColors.cAmber50;
        borderColor = AppColors.cAmber500;
        contentColor = AppColors.cAmber500;
        accentColor = AppColors.cAmber500;
        statusIcon = const Icon(Icons.sticky_note_2, size: 10, color: AppColors.cAmber500);
        statusLabel = "ORDINATO";
        break;
      case TableStatus.ready:
        cardBgColor = AppColors.cWhite;
        borderColor = AppColors.cEmerald500;
        contentColor = AppColors.cSlate800;
        accentColor = AppColors.cEmerald500;
        statusIcon = const Icon(Icons.notifications_active, size: 10, color: AppColors.cEmerald500);
        statusLabel = "PRONTO";
        break;
      case TableStatus.eating:
        cardBgColor = AppColors.cWhite;
        borderColor = AppColors.cIndigo100;
        contentColor = AppColors.cSlate800;
        accentColor = AppColors.cIndigo600;
        statusIcon = const Icon(Icons.restaurant, size: 10, color: AppColors.cIndigo600);
        statusLabel = "SERVITO";
        break;
      case TableStatus.free:
        cardBgColor = AppColors.cWhite;
        borderColor = AppColors.cEmerald100;
        contentColor = AppColors.cSlate400;
        accentColor = AppColors.cEmerald500;
        break;
    }

    // Usiamo ScaleTransition per far pulsare l'intera card
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: widget.table.status == TableStatus.ready ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cBlack.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Stack(
            children: [
              // Icona statica in alto a destra se READY (non pulsa più l'icona)
              if (widget.table.status == TableStatus.ready)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: AppColors.cEmerald500, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_active,
                        color: Colors.white, size: 12),
                  ),
                ),

              // PUNTINO DI STATO SE NON READY
              if (isOccupied && widget.table.status != TableStatus.ready)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.5), shape: BoxShape.circle),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.table.name,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isOccupied ? contentColor : AppColors.cSlate800),
                  ),
                  const SizedBox(height: 8),
                  if (isOccupied) ...[
                    Column(
                      children: [
                        // BADGE STATO DINAMICO
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (statusIcon != null) statusIcon,
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: accentColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // COPERTI E TOTALE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 12, color: contentColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text("${widget.table.guests}", style: TextStyle(fontWeight: FontWeight.bold, color: contentColor, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.cEmerald100, borderRadius: BorderRadius.circular(8)),
                      child: const Text("LIBERO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cEmerald500)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}