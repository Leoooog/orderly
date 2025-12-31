// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get waiterAppName => 'Orderly - Sala';

  @override
  String get kitchenAppName => 'Orderly - Cucina';

  @override
  String get adminAppName => 'Orderly - Admin';

  @override
  String get posAppName => 'Orderly - Cassa';

  @override
  String get appName => 'Orderly Pocket';

  @override
  String get loginInsertPin => 'Inserisci PIN Cameriere';

  @override
  String get loginPinError => 'PIN Errato';

  @override
  String get navTables => 'Sala';

  @override
  String get navMenu => 'MENU';

  @override
  String get navHistory => 'AL TAVOLO';

  @override
  String get tableStatusFree => 'LIBERO';

  @override
  String get tableStatusSeated => 'ATTESA';

  @override
  String get tableStatusOrdered => 'CUCINA';

  @override
  String get tableStatusReady => 'PRONTO';

  @override
  String get tableStatusServed => 'SERVITO';

  @override
  String get actionMove => 'Sposta Tavolo';

  @override
  String get actionMerge => 'Unisci Tavolo';

  @override
  String get actionQuickPay => 'Incasso Rapido';

  @override
  String get actionSplitPay => 'Cassa / Divisione';

  @override
  String get actionCancelTable => 'Annulla Tavolo';

  @override
  String get actionTransfer => 'Trasferisci su un tavolo libero';

  @override
  String get actionMergeDesc => 'Unisci a un tavolo occupato';

  @override
  String get actionPayTotalDesc => 'Paga tutto senza dividere';

  @override
  String get actionSplitDesc => 'Gestisci pagamenti parziali';

  @override
  String get actionResetDesc => 'Reset senza incasso';

  @override
  String dialogOpenTable(String tableName) {
    return 'Apertura $tableName';
  }

  @override
  String get dialogCovers => 'Quanti Coperti?';

  @override
  String get dialogConfirm => 'CONFERMA';

  @override
  String get dialogCancel => 'Annulla';

  @override
  String get dialogSave => 'Salva';

  @override
  String get dialogEdit => 'Modifica';

  @override
  String get dialogConfirmVoid => 'CONFERMA STORNO';

  @override
  String get btnOpen => 'Apri Tavolo';

  @override
  String get btnSendKitchen => 'INVIA COMANDA';

  @override
  String get btnFireCourse => 'DAI IL VIA';

  @override
  String get btnPay => 'PAGA';

  @override
  String get labelIngredients => 'INGREDIENTI';

  @override
  String get labelAllergens => 'ALLERGENI';

  @override
  String get labelNotes => 'Note Cucina';

  @override
  String get labelSearch => 'Cerca prodotto...';

  @override
  String get labelTotal => 'Totale';

  @override
  String get labelToPay => 'DA PAGARE';

  @override
  String get labelRemaining => 'RIMANENTE';

  @override
  String get labelSelectAll => 'Seleziona Tutto';

  @override
  String get labelDeselectAll => 'Deseleziona Tutto';

  @override
  String get msgPaymentSuccess => 'Pagamento registrato';

  @override
  String get msgOrderSent => 'Comanda inviata';

  @override
  String get msgChangesSaved => 'Modifiche salvate';
}
