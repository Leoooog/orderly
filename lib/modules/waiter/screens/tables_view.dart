import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';
import 'package:vibration/vibration.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';
import '../../../shared/widgets/payment_method_button.dart';
import '../providers/tables_provider.dart';
import '../../../logic/providers/auth_provider.dart';
import 'bill_screen.dart';
import 'widgets/table_card.dart';

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
        SnackBar(content: Text(AppLocalizations.of(context)!.tableMoved)));
  }

  void _performMerge(TableItem source, TableItem target) {
    ref.read(tablesProvider.notifier).mergeTable(source.id, target.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tableMerged)));
  }

  void _performCancel(TableItem table) {
    ref.read(tablesProvider.notifier).cancelTable(table.id);
    Navigator.pop(context); // Chiude dialog
    Navigator.pop(context); // Chiude bottom sheet azioni

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: context.colors.danger,
      content: Text(AppLocalizations.of(context)!.tableReset),
      duration: const Duration(seconds: 2),
    ));
  }

  void _performPayment(TableItem table, List<CartItem> paidItems) {
    ref.read(tablesProvider.notifier).processPayment(table.id, paidItems);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: context.colors.success,
      content: Text(AppLocalizations.of(context)!.msgPaymentSuccess),
      duration: const Duration(seconds: 2),
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

    // Responsive Bottom Sheet logic
    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 500 : double.infinity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // TRUCCO RESPONSIVE
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(AppLocalizations.of(context)!.tableActions(table.name),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.colors.textPrimary)),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(), // Evita bounce inutile
                  children: [
                    ListTile(
                      leading: Icon(Icons.compare_arrows,
                          color: context.colors.primary),
                      title: Text(AppLocalizations.of(context)!.actionMove),
                      subtitle:  Text(AppLocalizations.of(context)!.actionTransfer),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showTableSelectionDialog(table, isMerge: false);
                      },
                    ),
                    ListTile(
                      leading:
                      Icon(Icons.merge_type, color: context.colors.warning),
                      title: Text(AppLocalizations.of(context)!.actionMerge),
                      subtitle: Text(AppLocalizations.of(context)!.actionMergeDesc),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showTableSelectionDialog(table, isMerge: true);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.check_circle_outline,
                          color: context.colors.primary),
                      title: Text(AppLocalizations.of(context)!.actionQuickPay),
                      subtitle: Text(AppLocalizations.of(context)!.actionPayTotalDesc),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showPaymentDialog(table);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money,
                          color: context.colors.success),
                      title: Text(AppLocalizations.of(context)!.actionSplitPay),
                      subtitle: Text(AppLocalizations.of(context)!.actionSplitDesc),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openSplitBillScreen(table);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.close, color: context.colors.danger),
                      title: Text(AppLocalizations.of(context)!.actionCancelTable),
                      subtitle: Text(AppLocalizations.of(context)!.actionResetDesc),
                      onTap: () => _showConfirmCancelDialog(table),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DIALOGHI ---

  void _openSplitBillScreen(TableItem table) {
    // Responsive Logic per BillScreen (che è un full screen modal solitamente)
    // Se BillScreen supporta constraints, bene, altrimenti qui lo limitiamo
    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 700 : double.infinity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // TRUCCO
      useRootNavigator: true,
      builder: (ctx) => Align(
        alignment: Alignment.center, // Su tablet potrebbe essere un dialog centrato
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: isTablet ? const BorderRadius.vertical(top: Radius.circular(20)) : null
          ),
          // Dobbiamo passare constraints altezza per emulare full screen su mobile
          height: MediaQuery.sizeOf(context).height * (isTablet ? 0.85 : 1.0),
          child: ClipRRect(
            borderRadius: isTablet ? const BorderRadius.vertical(top: Radius.circular(20)) : BorderRadius.zero,
            child: BillScreen(
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
          ),
        ),
      ),
    );
  }

  void _showConfirmCancelDialog(TableItem table) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          surfaceTintColor: context.colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          // RESPONSIVE: Limita larghezza
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sx per leggibilità
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: context.colors.danger),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.msgAttention, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.msgConfirmCancelTable(table.name),
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
                ),
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
                      fillColor: context.colors.background),
                  onChanged: (v) => setStateDialog(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.msgBack,
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.danger,
                  foregroundColor: Colors.white),
              onPressed: pinController.text.length == 4
                  ? () => {
                if (pinController.text == '1234')
                  _performCancel(table)
                else
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                    backgroundColor: context.colors.danger,
                    content: Text(AppLocalizations.of(context)!.loginPinError),
                    duration: const Duration(seconds: 2),
                  ))
              }
                  : null,
              child: Text(AppLocalizations.of(context)!.dialogConfirm, style: const TextStyle(fontSize: 14),),
            ),
          ],
        );
      }),
    );
  }

  void _showPaymentDialog(TableItem table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        surfaceTintColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.dialogPaymentTable(table.name),
                  style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.labelPaymentTotal,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text("€ ${table.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: context.colors.primary)),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.dialogSelectPaymentMethod,
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PaymentMethodButton(
                      icon: Icons.credit_card,
                      label: AppLocalizations.of(context)!.cardPayment,
                      color: context.colors.primary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _performPayment(table, table.orders);
                      }),
                  PaymentMethodButton(
                      icon: Icons.money,
                      label: AppLocalizations.of(context)!.cashPayment,
                      color: context.colors.success,
                      onTap: () {
                        Navigator.pop(ctx);
                        _performPayment(table, table.orders);
                      }),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.dialogCancel,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showTableSelectionDialog(TableItem source, {required bool isMerge}) {
    final allTables = ref.read(tablesProvider);

    final candidates = allTables.where((t) {
      if (t.id == source.id) return false;
      return isMerge
          ? t.status != TableStatus.free
          : t.status == TableStatus.free;
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(isMerge ? AppLocalizations.of(context)!.dialogMergeTable : AppLocalizations.of(context)!.dialogMoveTable, style: const TextStyle(fontSize: 16)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: candidates.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.msgNoTablesAvailable, style: const TextStyle(fontSize: 14)))
            // RESPONSIVE GRID all'interno del dialog
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100, // Dimensione ideale cella
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0
              ),
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final t = candidates[index];
                return InkWell(
                  hoverColor: context.colors.hover,
                  onTap: () {
                    if (isMerge) {
                      _performMerge(source, t);
                    } else {
                      _performMove(source, t);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.divider,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.colors.divider),
                    ),
                    alignment: Alignment.center,
                    child: Text(t.name,
                        textAlign: TextAlign.center,
                        style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.dialogCancel, style: const TextStyle(fontSize: 14))),
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
            backgroundColor: context.colors.surface,
            surfaceTintColor: context.colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.dialogOpenTable(table.name),
                      style: TextStyle(
                          fontSize: 16, color: context.colors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.dialogGuests,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: Text("$guests",
                        style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (guests > 1) setStateDialog(() => guests--);
                        },
                        icon: Icon(Icons.remove_circle_outline,
                            size: 32, color: context.colors.textSecondary),
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        onPressed: () {
                          if (guests < 20) setStateDialog(() => guests++);
                        },
                        icon: Icon(Icons.add_circle_outline,
                            size: 32, color: context.colors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context)!.dialogCancel,
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _performOccupy(table, guests),
                child: Text(AppLocalizations.of(context)!.btnOpen,
                    style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    ref.listen<List<TableItem>>(tablesProvider, (previous, next) async {
      final prevReadyIds = previous
          ?.where((t) => t.status == TableStatus.ready)
          .map((t) => t.id)
          .toSet() ??
          {};
      final nextReadyIds = next
          .where((t) => t.status == TableStatus.ready)
          .map((t) => t.id)
          .toSet();

      if (nextReadyIds.difference(prevReadyIds).isNotEmpty) {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 500);
        }
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        titleSpacing: 24,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sala",
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            Text("Mario R. • Turno Pranzo",
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.settings, color: context.colors.textTertiary, size: 20),
              onPressed: () {
                context.push('/settings');
              }),
          IconButton(
            icon: Icon(Icons.logout, color: context.colors.danger, size: 20),
            onPressed: _performLogout,
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: context.colors.divider, height: 1)),
      ),
      // LAYOUT RESPONSIVE: Usa Align TopCenter + ConstrainedBox se sei su schermo molto largo
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200), // Max larghezza per desktop
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            // RESPONSIVE GRID LOGIC
            // SliverGridDelegateWithMaxCrossAxisExtent è magico:
            // Decide lui quante colonne mettere in base alla larghezza max desiderata per card (es. 160)
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160, // Larghezza ideale di una card tavolo
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9, // Rapporto altezza/larghezza
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return TableCard(
                table: table,
                onTap: () => _handleTableTap(table),
                onLongPress: () => _handleTableLongPress(table),
              );
            },
          ),
        ),
      ),
    );
  }
}