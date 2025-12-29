import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orderly/old/core/config/user_context.dart';
import 'package:orderly/old/core/config/supabase_client.dart';
import 'package:orderly/old/core/router/app_router.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRPinLoginPage extends StatefulWidget {
  const QRPinLoginPage({super.key});

  @override
  State<QRPinLoginPage> createState() => _QRPinLoginPageState();
}

class _QRPinLoginPageState extends State<QRPinLoginPage> {
  final pinController = TextEditingController();
  final restaurantIdController = TextEditingController();
  bool loading = false;

  String? selectedRestaurantId;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  @override
  void dispose() {
    pinController.dispose();
    restaurantIdController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        selectedRestaurantId = scanData.code;
      });
      controller.pauseCamera();
    });
  }

  Future<void> loginStaff() async {
    final pin = pinController.text.trim();
    final restaurantId = selectedRestaurantId;

    if (pin.isEmpty || restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona un ristorante e inserisci il PIN'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Chiama la Edge Function
      final staffRecord = await supabase.functions.invoke(
        "login_staff",
        body: {
          'restaurant_id': restaurantId,
          'pin': pin,
        },
      );

      if (staffRecord.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN o ristorante non valido')),
        );
        setState(() => loading = false);
        return;
      }
      // Salva la sessione Supabase restituita dall’Edge Function
      final refreshToken = staffRecord.data;
      if (refreshToken == null) {
        throw Exception('Sessione non ricevuta dall’Edge Function');
      }

      await supabase.auth.setSession(refreshToken);

      // Carica UserContext
      await UserContext.init();

      print('Login staff riuscito: ${UserContext.instance?.staffName}');



      // Naviga alla home dello staff
      if (!mounted) return;
      setState(() => loading = false);
      GoRouter.of(context).go('/staff');

    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore login staff: $e')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Staff'),
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/login'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blueAccent,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 8,
                  cutOutSize: 180,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              selectedRestaurantId == null
                  ? 'Scansiona il QR del ristorante'
                  : 'Ristorante selezionato: $selectedRestaurantId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: restaurantIdController,
              decoration: const InputDecoration(
                labelText: 'Oppure inserisci manualmente il Restaurant ID',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  selectedRestaurantId = value.isNotEmpty ? value : null;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : loginStaff,
                child: loading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Entra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
