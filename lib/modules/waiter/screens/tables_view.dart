import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/data/models/local/table_model.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';
import 'package:orderly/logic/providers/session_provider.dart';
import 'package:vibration/vibration.dart';

import '../../../core/utils/extensions.dart';
import '../../../data/models/enums/table_status.dart';
import '../../../shared/widgets/payment_method_button.dart';
import '../providers/tables_provider.dart';
import 'bill_screen.dart';
import 'widgets/table_card.dart';

class TablesView extends ConsumerStatefulWidget {
  const TablesView({super.key});

  @override
  ConsumerState<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends ConsumerState<TablesView> {
  // --- ACTIONS ---
  // All actions now call the controller provider

  void _performMove(TableUiModel source, TableUiModel target) {
    if (source.sessionId == null) return;
    ref
        .read(tablesControllerProvider.notifier)
        .moveTable(source.sessionId!, target.table.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tableMoved)));
  }

  void _performMerge(TableUiModel source, TableUiModel target) {
    if (source.sessionId == null || target.sessionId == null) return;
    ref
        .read(tablesControllerProvider.notifier)
        .mergeTables(source.sessionId!, target.sessionId!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tableMerged)));
  }

  void _performCancel(TableUiModel table) {
    if (table.sessionId == null) return;
    ref.read(tablesControllerProvider.notifier).closeTable(table.sessionId!);
    Navigator.pop(context); // Chiude dialog
    Navigator.pop(context); // Chiude bottom sheet azioni

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: context.colors.danger,
      content: Text(AppLocalizations.of(context)!.tableReset),
      duration: const Duration(seconds: 2),
    ));
  }

  void _performPayment(TableUiModel table) {
    if (table.activeSession == null) return;
    final allItemIds = table.activeSession!.orders
        .expand((order) => order.items.map((item) => item.id))
        .toList();

    ref
        .read(tablesControllerProvider.notifier)
        .processPayment(table.sessionId!, allItemIds);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: context.colors.success,
      content: Text(AppLocalizations.of(context)!.msgPaymentSuccess),
      duration: const Duration(seconds: 2),
    ));
  }

  void _performOccupy(TableUiModel table, int guests) {
    ref.read(tablesControllerProvider.notifier).openTable(table.table.id, guests);
    Navigator.pop(context);
    // No need to push route, UI will update when session is created
  }

  void _performLogout() {
    ref.read(sessionProvider.notifier).logout();
  }

  // --- UI HANDLERS ---

  void _handleTableTap(TableUiModel table) {
    if (table.isOccupied) {
      context.push('/menu/${table.sessionId}');
    } else {
      _showGuestsDialog(table);
    }
  }

  void _handleTableLongPress(TableUiModel table) {
    if (!table.isOccupied) return;

    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 500 : double.infinity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                  child: Text(
                      AppLocalizations.of(context)!
                          .tableActions(table.table.name),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.colors.textPrimary)),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    ListTile(
                      leading: Icon(Icons.compare_arrows,
                          color: context.colors.primary),
                      title: Text(AppLocalizations.of(context)!.actionMove),
                      subtitle:
                          Text(AppLocalizations.of(context)!.actionTransfer),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showTableSelectionDialog(table, isMerge: false);
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.merge_type, color: context.colors.warning),
                      title: Text(AppLocalizations.of(context)!.actionMerge),
                      subtitle:
                          Text(AppLocalizations.of(context)!.actionMergeDesc),
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
                      subtitle:
                          Text(AppLocalizations.of(context)!.actionPayTotalDesc),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showPaymentDialog(table);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money,
                          color: context.colors.success),
                      title: Text(AppLocalizations.of(context)!.actionSplitPay),
                      subtitle:
                          Text(AppLocalizations.of(context)!.actionSplitDesc),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openSplitBillScreen(table);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.close, color: context.colors.danger),
                      title:
                          Text(AppLocalizations.of(context)!.actionCancelTable),
                      subtitle:
                          Text(AppLocalizations.of(context)!.actionResetDesc),
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

  // --- DIALOGS ---

  void _openSplitBillScreen(TableUiModel table) {
    if (table.sessionId == null) return;
    final isTablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final double maxWidth = isTablet ? 700 : double.infinity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (ctx) => Align(
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius:
                  isTablet ? const BorderRadius.vertical(top: Radius.circular(20)) : null),
          height: MediaQuery.sizeOf(context).height * (isTablet ? 0.85 : 1.0),
          child: ClipRRect(
            borderRadius: isTablet
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : BorderRadius.zero,
            child: BillScreen(
              table: table,
              onConfirmPayment: (paidItemIds) {
                ref
                    .read(tablesControllerProvider.notifier)
                    .processPayment(table.sessionId!, paidItemIds);
                // The UI will update automatically via the stream
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmCancelDialog(TableUiModel table) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          surfaceTintColor: context.colors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: context.colors.danger),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.msgAttention,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!
                      .msgConfirmCancelTable(table.table.name),
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 14),
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
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 14)),
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: context.colors.danger,
                            content:
                                Text(AppLocalizations.of(context)!.loginPinError),
                            duration: const Duration(seconds: 2),
                          ))
                      }
                  : null,
              child: Text(
                AppLocalizations.of(context)!.dialogConfirm,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showPaymentDialog(TableUiModel table) {
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
              Text(
                  AppLocalizations.of(context)!
                      .dialogPaymentTable(table.table.name),
                  style: TextStyle(
                      fontSize: 16, color: context.colors.textSecondary)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.labelPaymentTotal,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text("€ ${table.activeSession?.totalAmount.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: context.colors.primary)),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.dialogSelectPaymentMethod,
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 12)),
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
                        _performPayment(table);
                      }),
                  PaymentMethodButton(
                      icon: Icons.money,
                      label: AppLocalizations.of(context)!.cashPayment,
                      color: context.colors.success,
                      onTap: () {
                        Navigator.pop(ctx);
                        _performPayment(table);
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
                style: TextStyle(
                    color: context.colors.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showTableSelectionDialog(TableUiModel source, {required bool isMerge}) {
    final allTables = ref.read(tablesControllerProvider).value ?? [];

    final candidates = allTables.where((t) {
      if (t.table.id == source.table.id) return false;
      return isMerge ? t.isOccupied : !t.isOccupied;
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
            isMerge
                ? AppLocalizations.of(context)!.dialogMergeTable
                : AppLocalizations.of(context)!.dialogMoveTable,
            style: const TextStyle(fontSize: 16)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: candidates.isEmpty
                ? Center(
                    child: Text(
                        AppLocalizations.of(context)!.msgNoTablesAvailable,
                        style: const TextStyle(fontSize: 14)))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 100,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0),
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
                          child: Text(t.table.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.dialogCancel,
                  style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showGuestsDialog(TableUiModel table) {
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
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      AppLocalizations.of(context)!
                          .dialogOpenTable(table.table.name),
                      style: TextStyle(
                          fontSize: 16, color: context.colors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.dialogGuests,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22)),
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
                    style: TextStyle(
                        color: context.colors.textSecondary, fontSize: 14)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _performOccupy(table, guests),
                child: Text(AppLocalizations.of(context)!.btnOpen,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesControllerProvider);

    ref.listen<AsyncValue<List<TableUiModel>>>(tablesControllerProvider,
        (previous, next) async {
      final prevReadyIds = previous?.value
              ?.where((t) => t.sessionStatus == TableSessionStatus.ready)
              .map((t) => t.table.id)
              .toSet() ??
          {};
      final nextReadyIds = next.value
              ?.where((t) => t.sessionStatus == TableSessionStatus.ready)
              .map((t) => t.table.id)
              .toSet() ??
          {};

      if (nextReadyIds.difference(prevReadyIds).isNotEmpty) {
        if (await Vibration.hasVibrator() ?? false) {
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
                style:
                    TextStyle(color: context.colors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.settings,
                  color: context.colors.textTertiary, size: 20),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: tablesAsync.when(
            data: (tables) => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Error: $err'),
            ),
          ),
        ),
      ),
    );
  }
}

