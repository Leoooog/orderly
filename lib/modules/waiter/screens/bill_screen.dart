import 'package:flutter/material.dart';
import 'package:orderly/config/restaurant_settings.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';
import 'package:orderly/shared/widgets/circle_button.dart';
import 'package:orderly/shared/widgets/quantity_control_button.dart';
import 'package:orderly/shared/widgets/payment_method_button.dart'; // Assicurati che questo file esista in shared/widgets


import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';

class BillScreen extends StatefulWidget {
  final TableItem table;
  final Function(List<CartItem>) onConfirmPayment;

  const BillScreen(
      {super.key, required this.table, required this.onConfirmPayment});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // STATO PER "PER PIATTO"
  Map<int, int> selection = {};

  // STATO PER "ALLA ROMANA"
  int _splitParts = 2;
  int _payingParts = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGICA "PER PIATTO" ---
  void _toggleItemFull(int id, int maxQty) {
    setState(() {
      if (selection.containsKey(id) && selection[id] == maxQty) {
        selection.remove(id);
      } else {
        selection[id] = maxQty;
      }
    });
  }

  void _updateQty(int id, int delta, int maxQty) {
    setState(() {
      int current = selection[id] ?? 0;
      int next = (current + delta).clamp(0, maxQty);
      if (next == 0) {
        selection.remove(id);
      } else {
        selection[id] = next;
      }
    });
  }

  double get _selectedTotalByItems {
    double total = 0;
    for (var item in widget.table.orders) {
      if (selection.containsKey(item.internalId)) {
        total += item.unitPrice * selection[item.internalId]!;
      }
    }
    return total;
  }

  bool get _isAllSelected {
    if (selection.isEmpty) return false;
    if (selection.length != widget.table.orders.length) return false;
    for (var item in widget.table.orders) {
      if ((selection[item.internalId] ?? 0) != item.qty) return false;
    }
    return true;
  }

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        selection.clear();
      } else {
        for (var item in widget.table.orders) {
          selection[item.internalId] = item.qty;
        }
      }
    });
  }

  List<CartItem> _getPaidItems() {
    List<CartItem> paid = [];
    for (var item in widget.table.orders) {
      if (selection.containsKey(item.internalId)) {
        paid.add(item.copyWith(qty: selection[item.internalId]!));
      }
    }
    return paid;
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final double totalAmount = widget.table.totalAmount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
                margin: EdgeInsets.only(top: 12, bottom: 4),
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(3))),
          ),

          // HEADER COMUNE
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        AppLocalizations.of(context)!
                            .tableName(widget.table.name),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary)),
                    Text(
                        AppLocalizations.of(context)!
                            .infoTotalAmount(widget.table.totalAmount.toCurrency()),
                        style: TextStyle(
                            fontSize: 16, color: colors.textSecondary)),
                  ],
                ),
                // Tab Selector Compatto
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _buildTabBtn(
                          AppLocalizations.of(context)!.billSplitEach, 0),
                      // Per piatto
                      _buildTabBtn(
                          AppLocalizations.of(context)!.billSplitEvenly, 1),
                      // Alla romana
                    ],
                  ),
                )
              ],
            ),
          ),

          Divider(height: 1, color: colors.divider),

          // BODY (TABS)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              // Disabilita swipe per evitare conflitti
              children: [
                _buildByItemView(totalAmount),
                _buildSplitEvenlyView(totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [BoxShadow(color: colors.shadow, blurRadius: 4)]
                    : [],
              ),
              child: Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected
                        ? colors.primary
                        : colors.textSecondary),
              ),
            ),
          );
        });
  }

  // --- VISTA 1: PER PIATTO ---
  Widget _buildByItemView(double totalAmount) {
    final colors = context.colors;
    final double toPay = _selectedTotalByItems;
    final double remaining = totalAmount - toPay;

    return Column(
      children: [
        // Action Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  _isAllSelected
                      ? AppLocalizations.of(context)!.allSelected
                      : AppLocalizations.of(context)!.selectToPay,
                  style: TextStyle(
                      color: colors.textSecondary, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _toggleSelectAll,
                child: Text(_isAllSelected
                    ? AppLocalizations.of(context)!.unselectAll
                    : AppLocalizations.of(context)!.selectAll),
              )
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.table.orders.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = widget.table.orders[index];
              final selectedQty = selection[item.internalId] ?? 0;
              final isSelected = selectedQty > 0;
              final done = item.qty == 0;

              return GestureDetector(
                onTap: () =>
                    !done ? _toggleItemFull(item.internalId, item.qty) : {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      // INFO ITEM
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected
                                        ? colors.primary
                                        : colors.textPrimary)),
                            if (item.selectedExtras.isNotEmpty)
                              Text(
                                  "+ ${item.selectedExtras.map((e) => e.name).join(', ')}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary)),
                            Text(
                                AppLocalizations.of(context)!
                                    .infoPriceEach(item.unitPrice.toCurrency()),
                                style: TextStyle(
                                    fontSize: 12, color: colors.textTertiary)),
                          ],
                        ),
                      ),

                      // CONTROLLI QUANTITÀ (UNIFICATI PER TUTTI)
                      // Avvolgiamo in GestureDetector vuoto per "assorbire" i click che non colpiscono i bottoni
                      // ma cadono nell'area dei controlli, evitando di triggerare il toggle della riga intera.
                      GestureDetector(
                        onTap: () {}, // Assorbe il tap locale
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.divider)), // Slate300 -> divider
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QuantityControlButton(
                                  icon: Icons.remove,
                                  isActive: selectedQty > 0,
                                  // Disabilitato se 0
                                  onTap: () => _updateQty(
                                      item.internalId, -1, item.qty)),
                              Container(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                constraints: BoxConstraints(minWidth: 40),
                                alignment: Alignment.center,
                                child: Text(
                                    // Mostra "3" se paghi 3, "1 / 3" se paghi parziale
                                    "$selectedQty / ${item.qty}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected
                                            ? colors.primary
                                            : colors.textTertiary)),
                              ),
                              QuantityControlButton(
                                  icon: Icons.add,
                                  isActive: selectedQty < item.qty,
                                  // Disabilitato se max
                                  onTap: () =>
                                      _updateQty(item.internalId, 1, item.qty)),
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

        _buildPaymentFooter(toPay, remaining, () {
          widget.onConfirmPayment(_getPaidItems());
          setState(() => selection.clear());
        }),
      ],
    );
  }

  // --- VISTA 2: ALLA ROMANA ---
  Widget _buildSplitEvenlyView(double totalAmount) {
    final colors = context.colors;
    // Calcoli
    final double amountPerPerson = totalAmount / _splitParts;
    final double payingNow = amountPerPerson * _payingParts;
    final double remaining = totalAmount - payingNow;

    return Column(
      children: [
        // USIAMO SingleChildScrollView PER EVITARE OVERFLOW SU SCHERMI PICCOLI
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24), // Padding ridotto per mobile
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  SizedBox(height: 16),
                  Text(
                      AppLocalizations.of(context)!.labelSplitEvenlyDescription,
                      style:
                          TextStyle(fontSize: 16, color: colors.textSecondary)),
                  SizedBox(height: 16),

                  // Slider Persone
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
                              })),
                      Container(
                        width: 100, // Larghezza ridotta
                        alignment: Alignment.center,
                        child: Text("$_splitParts",
                            style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary)),
                      ),
                      CircularIconButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _splitParts++)),
                    ],
                  ),
                  Text(AppLocalizations.of(context)!.totalPeople,
                      style: TextStyle(color: colors.textTertiary)),

                  SizedBox(height: 32),
                  Container(
                      width: double.infinity,
                      height: 1,
                      color: colors.divider),
                  SizedBox(height: 32),

                  Text(AppLocalizations.of(context)!.labelPartsToPay,
                      style:
                          TextStyle(fontSize: 16, color: colors.textSecondary)),
                  SizedBox(height: 16),

                  // Slider Quote
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularIconButton(
                          icon: Icons.remove,
                          small: true,
                          onTap: () => setState(() {
                                if (_payingParts > 1) _payingParts--;
                              })),
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text("$_payingParts",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: colors.primary)),
                      ),
                      CircularIconButton(
                          icon: Icons.add,
                          small: true,
                          onTap: () => setState(() {
                                if (_payingParts < _splitParts) _payingParts++;
                              })),
                    ],
                  ),
                  Text(AppLocalizations.of(context)!.infoPartsPaying(_payingParts, _splitParts),
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold)),

                  SizedBox(height: 32), // Spazio fisso invece di Spacer()

                  // Info Box
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: colors.infoSurfaceStrong,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.labelSinglePart,
                            style: TextStyle(color: colors.primary)),
                        Text(amountPerPerson.toCurrency(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colors.primary)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        _buildPaymentFooter(payingNow, remaining, () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Pagamento alla romana registrato (Simulazione)")));
        }),
      ],
    );
  }

  // --- FOOTER PAGAMENTO (Carta/Contanti) ---
  Widget _buildPaymentFooter(
      double toPay, double remaining, VoidCallback onPay) {
    final colors = context.colors;
    final bool canPay = toPay > 0.01;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.labelRemaining,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colors.textTertiary)),
                    Text(remaining.toCurrency(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textSecondary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppLocalizations.of(context)!.labelToPay,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primary)),
                    Text("€ ${toPay.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colors.primary)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Pulsanti Metodo di Pagamento
            Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: canPay ? 1.0 : 0.5,
                    child: PaymentMethodButton(
                        icon: Icons.credit_card,
                        label: AppLocalizations.of(context)!.cardPayment,
                        color: colors.primary,
                        onTap: canPay ? onPay : () {}),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Opacity(
                    opacity: canPay ? 1.0 : 0.5,
                    child: PaymentMethodButton(
                        icon: Icons.money,
                        label: AppLocalizations.of(context)!.cashPayment,
                        color: colors.success,
                        onTap: canPay ? onPay : () {}),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
