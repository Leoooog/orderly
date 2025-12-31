import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';
import 'package:vibration/vibration.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';
import '../../../shared/widgets/payment_method_button.dart';
import '../providers/tables_provider.dart';
import '../providers/auth_provider.dart';
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
      duration: Duration(seconds: 2),
    ));
  }

  void _performPayment(TableItem table, List<CartItem> paidItems) {
    ref.read(tablesProvider.notifier).processPayment(table.id, paidItems);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: context.colors.success,
      content: Text(AppLocalizations.of(context)!.msgPaymentSuccess),
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
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppLocalizations.of(context)!.tableActions(table.name),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: context.colors.textPrimary)),
            ),
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
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
                )
              ],
            )
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
      backgroundColor: context.colors.background,
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

  void _showConfirmCancelDialog(TableItem table) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          surfaceTintColor: context.colors.surface,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: context.colors.danger),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.msgAttention, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.msgConfirmCancelTable(table.name),
                style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 16),
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
                    duration: Duration(seconds: 2),
                  ))
              }
                  : null,
              child: Text(AppLocalizations.of(context)!.dialogConfirm, style: TextStyle(fontSize: 14),),
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
        title: Column(
          children: [
            Text(AppLocalizations.of(context)!.dialogPaymentTable(table.name),
                style:
                TextStyle(fontSize: 16, color: context.colors.textSecondary)),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.labelPaymentTotal,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("€ ${table.totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: context.colors.primary)),
            SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.dialogSelectPaymentMethod,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
            SizedBox(height: 8),
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
        title: Text(isMerge ? AppLocalizations.of(context)!.dialogMergeTable : AppLocalizations.of(context)!.dialogMoveTable, style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: candidates.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.msgNoTablesAvailable, style: TextStyle(fontSize: 14)))
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
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
                    color: context.colors.divider, // Slate100
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.divider), // Slate300 -> divider
                  ),
                  alignment: Alignment.center,
                  child: Text(t.name,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.dialogCancel, style: TextStyle(fontSize: 14))),
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
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Center(
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.dialogOpenTable(table.name),
                        style: TextStyle(
                            fontSize: 16, color: context.colors.textSecondary)),
                    SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.dialogGuests,
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24),
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
                    SizedBox(width: 32),
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
                      EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _performOccupy(table, guests),
                child: Text(AppLocalizations.of(context)!.btnOpen,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

      // Se ci sono nuovi ID nel set 'next' che non c'erano in 'prev', qualcuno è diventato pronto
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
          SizedBox(width: 16),
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(color: context.colors.divider, height: 1)),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
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
    );
  }
}
