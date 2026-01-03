import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/config/orderly_colors.dart';
import 'package:orderly/logic/providers/session_provider.dart';
import '../../l10n/app_localizations.dart';

class TenantSelectionScreen extends ConsumerStatefulWidget {
  const TenantSelectionScreen({super.key});

  @override
  ConsumerState<TenantSelectionScreen> createState() =>
      _TenantSelectionScreenState();
}

class _TenantSelectionScreenState extends ConsumerState<TenantSelectionScreen> {
  final _tenantCodeController = TextEditingController();

  @override
  void dispose() {
    _tenantCodeController.dispose();
    super.dispose();
  }

  void _connect() {
    final code = _tenantCodeController.text.trim();
    if (code.isEmpty) return;

    // Chiama il metodo setTenant nel notifier (vedi implementazione sotto)
    ref.read(sessionProvider.notifier).setTenant(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Osserviamo lo stato asincrono della sessione
    final sessionAsync = ref.watch(sessionProvider);
    final isLoading = sessionAsync.isLoading;

    // Listener per gestire gli errori (es. "Tenant non trovato")
    ref.listen(sessionProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        // Pulisce l'errore per visualizzazione (rimuove "Exception: ")
        final errorMsg = next.error.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMsg),
          backgroundColor: colors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 80,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.titleTenantSelection,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _tenantCodeController,
                    autocorrect: false,
                    enabled: !isLoading, // Disabilita input durante il loading
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.fieldTenantPlaceholder,
                      border: const OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      prefixIcon: const Icon(Icons.qr_code),
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tenantSelectionDevHelper,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.onPrimary,
                      ),
                    )
                        : Text(l10n.btnTenantSelection),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}