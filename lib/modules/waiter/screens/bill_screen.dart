import 'package:flutter/material.dart';
import 'package:orderly/shared/widgets/circle_button.dart';
import 'package:orderly/shared/widgets/quantity_control_button.dart';
import 'package:orderly/shared/widgets/payment_method_button.dart'; // Assicurati che questo file esista in shared/widgets

import '../../../config/themes.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';

class BillScreen extends StatefulWidget {
  final TableItem table;
  final Function(List<CartItem>) onConfirmPayment;

  const BillScreen({super.key, required this.table, required this.onConfirmPayment});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> with SingleTickerProviderStateMixin {
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
    final double totalAmount = widget.table.totalAmount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.cSlate50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 48,
                height: 6,
                decoration: BoxDecoration(color: AppColors.cSlate200, borderRadius: BorderRadius.circular(3))
            ),
          ),

          // HEADER COMUNE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cassa ${widget.table.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.cSlate900)),
                    Text("Totale: € ${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, color: AppColors.cSlate500)),
                  ],
                ),
                // Tab Selector Compatto
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.cSlate200, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _buildTabBtn("Per Piatto", 0),
                      _buildTabBtn("Alla Romana", 1),
                    ],
                  ),
                )
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cSlate200),

          // BODY (TABS)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Disabilita swipe per evitare conflitti
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
    return AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final isSelected = _tabController.index == index;
          return GestureDetector(
            onTap: () => _tabController.animateTo(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cWhite : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
              ),
              child: Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected ? AppColors.cIndigo600 : AppColors.cSlate500
                ),
              ),
            ),
          );
        }
    );
  }

  // --- VISTA 1: PER PIATTO ---
  Widget _buildByItemView(double totalAmount) {
    final double toPay = _selectedTotalByItems;
    final double remaining = totalAmount - toPay;

    return Column(
      children: [
        // Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  _isAllSelected ? "Tutto Selezionato" : "Seleziona cosa pagare",
                  style: const TextStyle(color: AppColors.cSlate500, fontWeight: FontWeight.bold)
              ),
              TextButton(
                onPressed: _toggleSelectAll,
                child: Text(_isAllSelected ? "Deseleziona Tutto" : "Seleziona Tutto"),
              )
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.table.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = widget.table.orders[index];
              final selectedQty = selection[item.internalId] ?? 0;
              final isSelected = selectedQty > 0;
              final done = item.qty == 0;

              return GestureDetector(
                onTap: () => !done ? _toggleItemFull(item.internalId, item.qty) : {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: done ? AppColors.cSlate200 : isSelected ? AppColors.cIndigo100.withValues(alpha: 0.3) : AppColors.cWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isSelected ? AppColors.cIndigo600 : AppColors.cSlate200,
                        width: isSelected ? 2 : 1
                    ),
                  ),
                  child: Row(
                    children: [
                      // INFO ITEM
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.cIndigo600 : AppColors.cSlate800)),
                            if (item.selectedExtras.isNotEmpty)
                              Text("+ ${item.selectedExtras.map((e)=>e.name).join(', ')}", style: const TextStyle(fontSize: 12, color: AppColors.cSlate500)),
                            Text("€ ${item.unitPrice.toStringAsFixed(2)} cad.", style: const TextStyle(fontSize: 12, color: AppColors.cSlate400)),
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
                              color: AppColors.cWhite,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: isSelected ? AppColors.cIndigo600 : AppColors.cSlate300)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QuantityControlButton(
                                  icon: Icons.remove,
                                  isActive: selectedQty > 0, // Disabilitato se 0
                                  onTap: () => _updateQty(item.internalId, -1, item.qty)
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                constraints: const BoxConstraints(minWidth: 40),
                                alignment: Alignment.center,
                                child: Text(
                                  // Mostra "3" se paghi 3, "1 / 3" se paghi parziale
                                    "$selectedQty / ${item.qty}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected ? AppColors.cIndigo600 : AppColors.cSlate400
                                    )
                                ),
                              ),
                              QuantityControlButton(
                                  icon: Icons.add,
                                  isActive: selectedQty < item.qty, // Disabilitato se max
                                  onTap: () => _updateQty(item.internalId, 1, item.qty)
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

        _buildPaymentFooter(toPay, remaining, () {
          widget.onConfirmPayment(_getPaidItems());
          setState(() => selection.clear());
        }),
      ],
    );
  }

  // --- VISTA 2: ALLA ROMANA ---
  Widget _buildSplitEvenlyView(double totalAmount) {
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
              padding: const EdgeInsets.all(24), // Padding ridotto per mobile
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text("In quante parti dividere?", style: TextStyle(fontSize: 16, color: AppColors.cSlate500)),
                  const SizedBox(height: 16),

                  // Slider Persone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularIconButton(icon: Icons.remove, onTap: () => setState(() {
                        if (_splitParts > 1) {
                          _splitParts--;
                          if (_payingParts > _splitParts) _payingParts = _splitParts;
                        }
                      })),
                      Container(
                        width: 100, // Larghezza ridotta
                        alignment: Alignment.center,
                        child: Text("$_splitParts", style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.cSlate900)),
                      ),
                      CircularIconButton(icon: Icons.add, onTap: () => setState(() => _splitParts++)),
                    ],
                  ),
                  const Text("Persone totali", style: TextStyle(color: AppColors.cSlate400)),

                  const SizedBox(height: 32),
                  Container(width: double.infinity, height: 1, color: AppColors.cSlate200),
                  const SizedBox(height: 32),

                  const Text("Quote da pagare ora:", style: TextStyle(fontSize: 16, color: AppColors.cSlate500)),
                  const SizedBox(height: 16),

                  // Slider Quote
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularIconButton(icon: Icons.remove, small: true, onTap: () => setState(() { if(_payingParts > 1) _payingParts--; })),
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text("$_payingParts", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.cIndigo600)),
                      ),
                      CircularIconButton(icon: Icons.add, small: true, onTap: () => setState(() { if(_payingParts < _splitParts) _payingParts++; })),
                    ],
                  ),
                  Text("$_payingParts su $_splitParts quote", style: const TextStyle(color: AppColors.cIndigo600, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 32), // Spazio fisso invece di Spacer()

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.cIndigo100.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Quota singola:", style: TextStyle(color: AppColors.cIndigo600)),
                        Text("€ ${amountPerPerson.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.cIndigo600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        _buildPaymentFooter(payingNow, remaining, () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pagamento alla romana registrato (Simulazione)")));
        }),
      ],
    );
  }

  // --- FOOTER PAGAMENTO (Carta/Contanti) ---
  Widget _buildPaymentFooter(double toPay, double remaining, VoidCallback onPay) {
    final bool canPay = toPay > 0.01;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cWhite,
        border: Border(top: BorderSide(color: AppColors.cSlate200)),
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
                    const Text("RIMANENTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cSlate400)),
                    Text("€ ${remaining.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cSlate500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("DA PAGARE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.cIndigo600)),
                    Text("€ ${toPay.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.cIndigo600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pulsanti Metodo di Pagamento
            Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: canPay ? 1.0 : 0.5,
                    child: PaymentMethodButton(
                        icon: Icons.credit_card,
                        label: "Carta",
                        color: AppColors.cIndigo600,
                        onTap: canPay ? onPay : () {}
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Opacity(
                    opacity: canPay ? 1.0 : 0.5,
                    child: PaymentMethodButton(
                        icon: Icons.money,
                        label: "Contanti",
                        color: AppColors.cEmerald500,
                        onTap: canPay ? onPay : () {}
                    ),
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
