import 'package:flutter/material.dart';

import '../../../config/themes.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';
import '../../../shared/widgets/circle_button.dart';
import '../../../shared/widgets/payment_method_button.dart';
import 'bill_screen.dart';

class TablesView extends StatefulWidget {
  final List<TableItem> tables;
  final Function(TableItem) onTableSelected;
  final Function(TableItem, TableItem) onMoveTable;
  final Function(TableItem, TableItem) onMergeTable;
  final Function(TableItem, List<CartItem>) onPayment;
  final VoidCallback onLogout; // Callback per il logout

  const TablesView({
    super.key,
    required this.tables,
    required this.onTableSelected,
    required this.onMoveTable,
    required this.onMergeTable,
    required this.onPayment,
    required this.onLogout, // Richiesto nel costruttore
  });

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {

  void _handleTableTap(TableItem table) {
    if (table.status == 'free') {
      _showGuestsDialog(table);
    } else {
      widget.onTableSelected(table);
    }
  }

  void _handleTableLongPress(TableItem table) {
    if (table.status == 'free') return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cWhite,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Azioni ${table.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.cSlate800)),
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows, color: AppColors.cIndigo600),
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
            // --- NUOVO TASTO PER INCASSO RAPIDO ---
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.cIndigo600),
              title: const Text("Incasso Rapido (Totale)"),
              subtitle: const Text("Paga tutto senza dividere"),
              onTap: () {
                Navigator.pop(ctx);
                _showPaymentDialog(table); // Ora viene utilizzato qui!
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: AppColors.cEmerald500),
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

  void _openSplitBillScreen(TableItem table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cSlate50,
      useRootNavigator: true,
      builder: (ctx) => BillScreen(
          table: table,
          onConfirmPayment: (paidItems) {
            widget.onPayment(table, paidItems);

            // Se il tavolo è diventato libero (pagamento totale), chiudi il sheet
            if (table.status == 'free') {
              Navigator.pop(ctx);
            }
          }
      ),
    );
  }

  // Dialogo per il pagamento rapido (Totale)
  void _showPaymentDialog(TableItem table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cWhite,
        surfaceTintColor: AppColors.cWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Text("Incasso ${table.name}", style: const TextStyle(fontSize: 16, color: AppColors.cSlate500)),
            const SizedBox(height: 8),
            const Text("Totale da incassare", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cSlate800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("€ ${table.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.cIndigo600)),
            const SizedBox(height: 24),
            const Text("Seleziona metodo (Paga Tutto):", style: TextStyle(color: AppColors.cSlate500, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PaymentMethodButton(icon: Icons.credit_card, label: "Carta", color: AppColors.cIndigo600, onTap: () {
                  Navigator.pop(ctx);
                  widget.onPayment(table, table.orders); // Paga l'intera lista ordini
                }),
                PaymentMethodButton(icon: Icons.money, label: "Contanti", color: AppColors.cEmerald500, onTap: () {
                  Navigator.pop(ctx);
                  widget.onPayment(table, table.orders); // Paga l'intera lista ordini
                }),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla", style: TextStyle(color: AppColors.cSlate500)),
          ),
        ],
      ),
    );
  }

  void _showTableSelectionDialog(TableItem source, {required bool isMerge}) {
    final candidates = widget.tables.where((t) {
      if (t.id == source.id) return false;
      return isMerge ? t.status == 'occupied' : t.status == 'free';
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final t = candidates[index];
              return InkWell(
                onTap: () {
                  if (isMerge) {
                    widget.onMergeTable(source, t);
                  } else {
                    widget.onMoveTable(source, t);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cSlate100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cSlate300),
                  ),
                  alignment: Alignment.center,
                  child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
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
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: AppColors.cWhite,
                surfaceTintColor: AppColors.cWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Center(child: Column(
                  children: [
                    Text("Apertura ${table.name}", style: const TextStyle(fontSize: 16, color: AppColors.cSlate500)),
                    const SizedBox(height: 4),
                    const Text("Quanti Coperti?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                )),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text("$guests", style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.cIndigo600)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularIconButton(icon: Icons.remove, onTap: () {
                          if(guests > 1) setStateDialog(() => guests--);
                        }),
                        const SizedBox(width: 32),
                        CircularIconButton(icon: Icons.add, onTap: () {
                          if(guests < 20) setStateDialog(() => guests++);
                        }),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Annulla", style: TextStyle(color: AppColors.cSlate500)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cIndigo600,
                      foregroundColor: AppColors.cWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Nota: Qui modifichiamo l'oggetto, ma il setState vero avverrà nel padre o al ritorno
                      table.status = 'occupied';
                      table.guests = guests;
                      Navigator.pop(ctx);
                      widget.onTableSelected(table);
                    },
                    child: const Text("Apri Tavolo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cSlate50,
      appBar: AppBar(
        backgroundColor: AppColors.cWhite,
        elevation: 0,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Sala", style: TextStyle(color: AppColors.cSlate800, fontWeight: FontWeight.bold, fontSize: 24)),
            Text("Mario R. • Turno Pranzo", style: TextStyle(color: AppColors.cSlate500, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.cSlate400), onPressed: () {}),
          // Pulsante Logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.cRose500),
            onPressed: widget.onLogout,
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.cSlate100, height: 1)
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: widget.tables.length,
        itemBuilder: (context, index) {
          final table = widget.tables[index];
          final isOccupied = table.status == 'occupied';

          return GestureDetector(
            onTap: () => _handleTableTap(table),
            onLongPress: () => _handleTableLongPress(table),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isOccupied ? AppColors.cOrange50 : AppColors.cWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOccupied ? AppColors.cOrange200 : AppColors.cEmerald100,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.cBlack.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nome Tavolo
                      Center(
                        child: Text(
                          table.name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isOccupied ? AppColors.cOrange700 : AppColors.cSlate800),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      if (isOccupied)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.cWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cOrange200)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people, size: 14, color: AppColors.cOrange700),
                                  const SizedBox(width: 4),
                                  Text("${table.guests}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.cOrange700, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Totale Parziale
                            Text("€ ${table.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.cSlate800)),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.cEmerald100, borderRadius: BorderRadius.circular(8)),
                          child: const Text("LIBERO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cEmerald500)),
                        )
                    ],
                  ),
                  // Indicatore Long Press
                  if (isOccupied)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(color: AppColors.cOrange200, shape: BoxShape.circle),
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}