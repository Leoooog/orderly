import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/config/orderly_colors.dart';
import 'package:orderly/modules/waiter/providers/menu_provider.dart';
import 'package:orderly/shared/widgets/circle_button.dart';
import 'package:orderly/shared/widgets/quantity_control_button.dart';
import 'package:orderly/shared/widgets/payment_method_button.dart';

import '../../../core/utils/extensions.dart';
import '../../../data/models/menu/menu_item.dart';
import '../../../data/models/session/order.dart';
import '../../../data/models/session/order_item.dart';
import '../../../data/models/session/table_session.dart';

class BillScreen extends ConsumerStatefulWidget {
  final TableSession table;
  final Function(List<OrderItem>) onConfirmPayment;

  const BillScreen(
      {super.key, required this.table, required this.onConfirmPayment});

  @override
  ConsumerState<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends ConsumerState<BillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<OrderItem> _allItems;
  late Future<Map<String, MenuItem>> _menuItemsFuture;

  // STATO PER "PER PIATTO"
  Map<String, int> selection = {};

  // STATO PER "ALLA ROMANA"
  int _splitParts = 2;
  int _payingParts = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allItems = widget.table.orders.expand((order) => order.items).toList();
    _menuItemsFuture = _fetchMenuItems();
  }

  Future<Map<String, MenuItem>> _fetchMenuItems() async {
    final Map<String, MenuItem> menuItems = {};
    for (var item in _allItems) {
      if (!menuItems.containsKey(item.menuItemId)) {
        final menuItem = await ref
            .read(menuItemsProvider.notifier)
            .getMenuItemById(item.menuItemId);
        if (menuItem != null) {
          menuItems[item.menuItemId] = menuItem;
        }
      }
    }
    return menuItems;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGICA "PER PIATTO" ---
  void _toggleItemFull(OrderItem item) {
    setState(() {
      if (selection.containsKey(item.id) &&
          selection[item.id] == item.quantity) {
        selection.remove(item.id);
      } else {
        selection[item.id] = item.quantity;
      }
    });
  }

  void _updateQty(OrderItem item, int delta) {
    setState(() {
      int current = selection[item.id] ?? 0;
      int next = (current + delta).clamp(0, item.quantity);
      if (next == 0) {
        selection.remove(item.id);
      } else {
        selection[item.id] = next;
      }
    });
  }

  bool get _isAllSelected {
    if (selection.isEmpty) return false;
    if (_allItems.isEmpty) return false;
    if (selection.length != _allItems.length) return false;
    for (var item in _allItems) {
      if ((selection[item.id] ?? 0) != item.quantity) return false;
    }
    return true;
  }

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        selection.clear();
      } else {
        for (var item in _allItems) {
          selection[item.id] = item.quantity;
        }
      }
    });
  }

  List<OrderItem> _getPaidItems() {
    List<OrderItem> paid = [];
    for (var item in _allItems) {
      if (selection.containsKey(item.id)) {
        paid.add(item.copyWith(quantity: selection[item.id]));
      }
    }
    return paid;
  }

  double _calculateToPay(Map<String, MenuItem> menuItems) {
    double total = 0;
    for (var item in _allItems) {
      if (selection.containsKey(item.id)) {
        final menuItem = item.menuItem ?? menuItems[item.menuItemId];
        if (menuItem != null) {
          final selectedQty = selection[item.id] ?? 0;
          // Create a temporary item with the menuItem to use the extension
          final itemWithMenuData = item.copyWith(menuItem: menuItem);
          total += itemWithMenuData.priceEach * selectedQty;
        }
      }
    }
    return total;
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: constraints.maxHeight * 0.9,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // --- Drag Handle Section ---
            SizedBox(
              height: 30,
              child: Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // --- HEADER ---
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Title Section
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .tableName(widget.table.tableId),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)!.infoTotalAmount(
                                    widget.table.totalAmount.toCurrency(ref)),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Tabs Section
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.divider,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTabBtn(
                                  AppLocalizations.of(context)!.billSplitEach,
                                  0),
                            ),
                            Expanded(
                              child: _buildTabBtn(
                                  AppLocalizations.of(context)!.billSplitEvenly,
                                  1),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: colors.divider),

            // --- BODY (TABS) ---
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildByItemView(),
                  _buildSplitEvenlyView(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabBtn(String label, int index) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isSelected = _tabController.index == index;
        return GestureDetector(
          onTap: () => _tabController.animateTo(index),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? colors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [BoxShadow(color: colors.shadow, blurRadius: 4)]
                  : [],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- VISTA 1: PER PIATTO ---
  Widget _buildByItemView() {
    return Column(
      children: [
        // Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Text(
                _isAllSelected
                    ? AppLocalizations.of(context)!.allSelected
                    : AppLocalizations.of(context)!.selectToPay,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _toggleSelectAll,
                child: Text(
                  _isAllSelected
                      ? AppLocalizations.of(context)!.unselectAll
                      : AppLocalizations.of(context)!.selectAll,
                ),
              )
            ],
          ),
        ),

        // List
        Expanded(
          child: FutureBuilder<Map<String, MenuItem>>(
            future: _menuItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final menuItems = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _allItems[index];
                        final menuItem = menuItems[item.menuItemId];

                        if (menuItem == null) {
                          return const SizedBox
                              .shrink(); // Or a placeholder
                        }

                        final selectedQty = selection[item.id] ?? 0;
                        final isSelected = selectedQty > 0;
                        final done = item.quantity == 0;
                        final colors = context.colors;

                        return GestureDetector(
                          onTap: () => !done ? _toggleItemFull(item) : {},
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: done
                                  ? colors.divider
                                  : isSelected
                                      ? colors.infoSurfaceMedium
                                      : colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // INFO ITEM
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menuItem.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected
                                              ? colors.primary
                                              : colors.textPrimary,
                                        ),
                                      ),
                                      if (item.selectedExtras.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            "+ ${item.selectedExtras.length} extras",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .infoPriceEach(menuItem.price
                                                  .toCurrency(ref)),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // CONTROLLI QUANTITÀ
                                GestureDetector(
                                  onTap: () {},
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primary
                                            : colors.divider,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        QuantityControlButton(
                                          icon: Icons.remove,
                                          isActive: selectedQty > 0,
                                          onTap: () => _updateQty(item, -1),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          constraints: const BoxConstraints(
                                              minWidth: 40),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "$selectedQty / ${item.quantity}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isSelected
                                                  ? colors.primary
                                                  : colors.textTertiary,
                                            ),
                                          ),
                                        ),
                                        QuantityControlButton(
                                          icon: Icons.add,
                                          isActive:
                                              selectedQty < item.quantity,
                                          onTap: () => _updateQty(item, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildPaymentFooter(
                    _calculateToPay(menuItems),
                    widget.table.totalAmount - _calculateToPay(menuItems),
                    () {
                      widget.onConfirmPayment(_getPaidItems());
                      setState(() => selection.clear());
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --- VISTA 2: ALLA ROMANA ---
  Widget _buildSplitEvenlyView() {
    final colors = context.colors;
    final double totalAmount = widget.table.totalAmount;
    final double amountPerPerson =
        _splitParts > 0 ? totalAmount / _splitParts : 0;
    final double payingNow = amountPerPerson * _payingParts;
    final double remaining = totalAmount - payingNow;

    return LayoutBuilder(builder: (context, constraints) {
      // Dynamic font sizing calculation
      // We base it on height, but cap it so it doesn't get absurdly huge
      final double mainCounterSize =
          (constraints.maxHeight * 0.1).clamp(32.0, 56.0);
      final double subCounterSize =
          (constraints.maxHeight * 0.08).clamp(24.0, 40.0);

      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    AppLocalizations.of(context)!.labelSplitEvenlyDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                  ),
                  const Spacer(flex: 3),
                  // Slider Persone
                  Text(
                    AppLocalizations.of(context)!.totalPeople.toUpperCase(),
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularIconButton(
                        icon: Icons.remove,
                        onTap: () => setState(() {
                          if (_splitParts > 1) {
                            _splitParts--;
                            if (_payingParts > _splitParts) {
                              _payingParts = _splitParts;
                            }
                          }
                        }),
                      ),
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text(
                          "$_splitParts",
                          style: TextStyle(
                            fontSize: mainCounterSize, // Dynamic Font
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      CircularIconButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _splitParts++),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  const Divider(),
                  const Spacer(flex: 3),
                  // Slider Quote
                  Text(
                    AppLocalizations.of(context)!
                        .labelPartsToPay
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularIconButton(
                        icon: Icons.remove,
                        small: true,
                        onTap: () => setState(() {
                          if (_payingParts > 1) _payingParts--;
                        }),
                      ),
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text(
                          "$_payingParts",
                          style: TextStyle(
                            fontSize: subCounterSize, // Dynamic Font
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      CircularIconButton(
                        icon: Icons.add,
                        small: true,
                        onTap: () => setState(() {
                          if (_payingParts < _splitParts) _payingParts++;
                        }),
                      ),
                    ],
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .infoPartsPaying(_payingParts, _splitParts),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(flex: 4),
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.infoSurfaceStrong,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.labelSinglePart,
                          style: TextStyle(color: colors.primary),
                        ),
                        const Spacer(),
                        Text(
                          amountPerPerson.toCurrency(ref),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          _buildPaymentFooter(payingNow, remaining, () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text("Pagamento alla romana registrato (Simulazione)")));
          }),
        ],
      );
    });
  }

  // --- FOOTER PAGAMENTO (STATICO & VELOCE) ---
  Widget _buildPaymentFooter(
      double toPay, double remaining, VoidCallback onPay) {
    final colors = context.colors;
    final bool canPay = toPay > 0.01;

    return LayoutBuilder(builder: (context, constraints) {
      final double horizontalPadding = constraints.maxWidth * 0.06;
      final double gapSize = constraints.maxWidth * 0.04;
      final double buttonHeight = constraints.maxWidth * 0.18;

      return Container(
        padding:
            EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          // Manteniamo l'ombra perché è statica e non pesa sulla performance
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(top: BorderSide(color: colors.divider.withValues(alpha:0.5))),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Totals Row ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // REMAINING
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.labelRemaining,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // NESSUNA ANIMAZIONE: Testo diretto
                        Text(
                          remaining.toCurrency(ref),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // TO PAY
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .labelToPay
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: canPay ? colors.primary : colors.textTertiary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // NESSUNA ANIMAZIONE: Testo diretto
                        Text(
                          toPay.toCurrency(ref),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: canPay ? colors.primary : colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: gapSize),

              // --- Buttons Row ---
              SizedBox(
                height: buttonHeight,
                // Usiamo Opacity standard invece di AnimatedOpacity per evitare calcoli frame-per-frame
                child: Opacity(
                  opacity: canPay ? 1.0 : 0.4,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: PaymentMethodButton(
                          icon: Icons.credit_card,
                          label: AppLocalizations.of(context)!.cardPayment,
                          color: colors.primary,
                          onTap: canPay ? onPay : () {
                            //TODO
                          },
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 10,
                        child: PaymentMethodButton(
                          icon: Icons.money,
                          label: AppLocalizations.of(context)!.cashPayment,
                          color: colors.success,
                          onTap: canPay ? onPay : () {
                            //TODO
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
