import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';

// Import Providers
import '../../../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/tables_provider.dart'; // NECESSARIO per ascoltare gli aggiornamenti del tavolo

// Import Widgets Segmentati
import 'menu_widgets/menu_tab.dart';
import 'menu_widgets/history_tab.dart';
import 'menu_widgets/cart_sheet.dart';

class MenuView extends ConsumerStatefulWidget {
  final TableItem table;
  final Function(List<CartItem>) onSuccess;

  const MenuView(
      {super.key,
      required this.table,
      required this.onSuccess});

  @override
  ConsumerState<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends ConsumerState<MenuView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double _minHeight = 85.0;
  double _maxHeight = 0.0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBack() {
    final currentCart = ref.read(cartProvider);
    if (currentCart.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.colors.surface,
          title: Text(AppLocalizations.of(context)!.msgChangesNotSaved),
          content: Text(AppLocalizations.of(context)!.msgExitWithoutSaving),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context)!.dialogCancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.danger,
                  foregroundColor: context.colors.textInverse),
              onPressed: () {
                back();
              },
              child: Text(AppLocalizations.of(context)!.exit),
            )
          ],
        ),
      );
    } else {
      back();
    }
  }

  void _handleSendOrder() {
    final currentCart = ref.read(cartProvider);
    widget.onSuccess(currentCart);
    ref.read(cartProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    _maxHeight = size.height * 0.75;

    final cart = ref.watch(cartProvider);
    final allTables = ref.watch(tablesProvider);
    final currentTable = allTables.firstWhere((t) => t.id == widget.table.id,
        orElse: () => widget.table);

    ref.listen<List<CartItem>>(cartProvider, (previous, next) {
      if (next.isEmpty && _isExpanded) {
        _controller.animateTo(0, curve: Curves.easeOutQuint);
        setState(() => _isExpanded = false);
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: colors.divider))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.chevron_left,
                                color: colors.textSecondary),
                            onPressed: _handleBack),
                        Expanded(
                          child: Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .tableName(currentTable.name),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary)),
                              ),
                              Text(
                                  AppLocalizations.of(context)!
                                      .labelGuests(currentTable.guests),
                                  style: TextStyle(
                                      fontSize: 12, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                ),

                // TAB BAR
                TabBar(
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.textSecondary,
                  indicatorColor: colors.primary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.navMenu),
                    Tab(
                        text:
                            "${AppLocalizations.of(context)!.navTableHistory} (${currentTable.orders.length})"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      const MenuTab(),
                      HistoryTab(table: currentTable),
                    ],
                  ),
                ),
              ],
            ),
            if (cart.isNotEmpty) _buildBackdrop(),
            if (cart.isNotEmpty)
              CartSheet(
                controller: _controller,
                minHeight: _minHeight,
                maxHeight: _maxHeight,
                isExpanded: _isExpanded,
                onExpandChange: (val) => setState(() => _isExpanded = val),
                onSendOrder: _handleSendOrder,
              ),
            if (cart.isNotEmpty) _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: _controller.value == 0,
          child: GestureDetector(
            onTap: () {
              _controller.animateTo(0, curve: Curves.easeOutQuint);
              setState(() => _isExpanded = false);
            },
            child: Container(
                color: context.colors.backdrop
                    .withValues(alpha: 0.4 * _controller.value)),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, 100 * (1 - _controller.value)),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: context.colors.surface,
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.success,
                        foregroundColor: context.colors.textInverse,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: _handleSendOrder,
                    icon: const Icon(Icons.send),
                    label: Text(AppLocalizations.of(context)!.btnSendKitchen,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  )),
            ),
          ),
        );
      },
    );
  }

  void back() {
    if(context.canPop()) {
      context.pop(context);
    }
    context.go('/tables');

    ref.read(cartProvider.notifier).clear();
  }
}
