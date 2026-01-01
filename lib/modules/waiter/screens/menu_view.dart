import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/config/orderly_colors.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/table_item.dart';

// Import Providers
import '../../../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/tables_provider.dart';

// Import Widgets Segmentati
import 'menu_widgets/menu_tab.dart';
import 'menu_widgets/history_tab.dart';
import 'menu_widgets/cart_sheet.dart';

class MenuView extends ConsumerStatefulWidget {
  final TableItem table;
  final Function(List<CartItem>) onSuccess;

  const MenuView({super.key, required this.table, required this.onSuccess});

  @override
  ConsumerState<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends ConsumerState<MenuView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Altezza minima della barra del carrello (collapsed)
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
    final size = MediaQuery.sizeOf(context);

    // Responsive Logic
    final isTablet = size.shortestSide > 600;
    final isLandscape = size.width > size.height;
    // Larghezza massima per il contenuto centrale (Header, Tab, etc.)
    final double maxContentWidth = isTablet || isLandscape ? 600.0 : double.infinity;

    final cart = ref.watch(cartProvider);
    final allTables = ref.watch(tablesProvider);

    final currentTable = allTables.firstWhere(
            (t) => t.id == widget.table.id,
        orElse: () => widget.table
    );

    ref.listen<List<CartItem>>(cartProvider, (previous, next) {
      if (next.isEmpty && _isExpanded) {
        _controller.animateTo(0, curve: Curves.easeOutQuint);
        setState(() => _isExpanded = false);
      }
    });

    return LayoutBuilder(builder: (context, constraints) {
      final double heightFactor = (isLandscape && !isTablet) ? 0.85 : 0.75;
      _maxHeight = constraints.maxHeight * heightFactor;

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: colors.background,
          body: Stack(
            children: [
              // --- MAIN CONTENT (Limitato in larghezza e centrato) ---
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    children: [
                      // HEADER
                      SafeArea(
                        bottom: false,
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: colors.divider))),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: Icon(Icons.chevron_left, color: colors.textSecondary),
                                  onPressed: _handleBack,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          AppLocalizations.of(context)!.tableName(currentTable.name),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.labelGuests(currentTable.guests),
                                          style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ),
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
                          Tab(text: "${AppLocalizations.of(context)!.navTableHistory} (${currentTable.orders.length})"),
                        ],
                      ),
                      // TAB CONTENT
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
                ),
              ),

              // --- BACKDROP ---
              if (cart.isNotEmpty) _buildBackdrop(),

              // --- CART SHEET ---
              // CORREZIONE: Qui abbiamo rimosso ConstrainedBox/Align.
              // CartSheet è tornato ad essere figlio diretto dello Stack.
              // La responsività deve essere gestita DENTRO CartSheet.dart (vedi punto 2).
              if (cart.isNotEmpty)
                CartSheet(
                  controller: _controller,
                  minHeight: _minHeight,
                  maxHeight: _maxHeight,
                  isExpanded: _isExpanded,
                  onExpandChange: (val) => setState(() => _isExpanded = val),
                  onSendOrder: _handleSendOrder,
                ),

              // --- SEND BUTTON ---
              // Il bottone fluttuante lo limitiamo in larghezza qui perché usa Transform, non Positioned.
              if (cart.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: _buildSendButton(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
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
    // Nota: Il posizionamento verticale (bottom: 0) è gestito dallo Stack/Align padre
    // Qui gestiamo solo l'animazione di entrata/uscita verticale
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
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
        );
      },
    );
  }

  void back() {
    if (context.canPop()) {
      context.pop();
    }
    context.go('/tables');
    ref.read(cartProvider.notifier).clear();
  }
}