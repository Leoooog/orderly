// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get headerAppMetadata => '--- Titoli e Info Generali ---';

  @override
  String get appName => 'Orderly Pocket';

  @override
  String get waiterAppName => 'Orderly - Sala';

  @override
  String get kitchenAppName => 'Orderly - Cucina';

  @override
  String get posAppName => 'Orderly - Cassa';

  @override
  String get adminAppName => 'Orderly - Admin';

  @override
  String get headerAuth => '--- Autenticazione ---';

  @override
  String get loginInsertPin => 'Inserisci PIN Cameriere';

  @override
  String get loginPinError => 'PIN Errato';

  @override
  String get headerNavigation => '--- Navigazione ---';

  @override
  String get navTables => 'Sala';

  @override
  String get navMenu => 'MENU';

  @override
  String get navTableHistory => 'AL TAVOLO';

  @override
  String get msgBack => 'Indietro';

  @override
  String get exit => 'Esci';

  @override
  String get headerTableStatus => '--- Stati del Tavolo (Logica) ---';

  @override
  String get tableStatusFree => 'LIBERO';

  @override
  String get tableStatusSeated => 'ATTESA';

  @override
  String get tableStatusOrdered => 'ORDINATO';

  @override
  String get tableStatusReady => 'PRONTO';

  @override
  String get tableStatusEating => 'SERVITO';

  @override
  String get headerTableActions => '--- Gestione Tavoli (Sala) ---';

  @override
  String tableActions(String tableName) {
    return 'Azioni Tavolo $tableName';
  }

  @override
  String tableName(String tableName) {
    return 'Tavolo $tableName';
  }

  @override
  String dialogOpenTable(String tableName) {
    return 'Apertura $tableName';
  }

  @override
  String get btnOpen => 'Apri Tavolo';

  @override
  String get dialogGuests => 'Quanti Coperti?';

  @override
  String labelGuests(int guests) {
    return 'Coperti: $guests';
  }

  @override
  String get actionMove => 'Sposta Tavolo';

  @override
  String get actionTransfer => 'Trasferisci su un tavolo libero';

  @override
  String get dialogMoveTable => 'Sposta su...';

  @override
  String get actionMerge => 'Unisci Tavolo';

  @override
  String get actionMergeDesc => 'Unisci a un tavolo occupato';

  @override
  String get dialogMergeTable => 'Unisci a...';

  @override
  String get actionCancelTable => 'Annulla Tavolo';

  @override
  String get actionResetDesc => 'Chiudi tavolo senza incasso';

  @override
  String msgConfirmCancelTable(String tableName) {
    return 'Stai per annullare il tavolo $tableName.\n\nTutti gli ordini correnti verranno persi e il tavolo tornerà libero senza registrare incasso.\n\nSei sicuro?';
  }

  @override
  String msgTableOpened(String tableName) {
    return 'Tavolo $tableName aperto';
  }

  @override
  String get tableMoved => 'Tavolo spostato con successo';

  @override
  String get tableMerged => 'Tavoli uniti con successo';

  @override
  String get tableReset => 'Tavolo annullato e resettato';

  @override
  String get msgNoTablesAvailable => 'Nessun tavolo disponibile';

  @override
  String get headerMenuCart => '--- Menu e Carrello ---';

  @override
  String get labelSearch => 'Cerca prodotto...';

  @override
  String get labelNoProducts => 'Nessun prodotto trovato';

  @override
  String get labelIngredients => 'INGREDIENTI';

  @override
  String get labelAllergens => 'ALLERGENI';

  @override
  String get cartSheetTitle => 'Comanda';

  @override
  String cartSheetItemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli',
      one: '1 articolo',
      zero: 'Nessun articolo',
    );
    return '$_temp0';
  }

  @override
  String cartEditingItem(String itemName) {
    return 'Stai modificando: $itemName';
  }

  @override
  String get cartEditingQuantity => 'Quanti piatti vuoi modificare?';

  @override
  String get dialogMoveToCourse => 'Sposta in:';

  @override
  String get labelExtras => 'Aggiunte (Extra):';

  @override
  String get labelNotesTitle => 'Note Cucina';

  @override
  String get fieldNotesPlaceholder => 'Es. No cipolla...';

  @override
  String get btnEdit => 'MODIFICA';

  @override
  String get labelEdit => 'Modifica';

  @override
  String get subtitleEditItemAction => 'Cambia note o varianti';

  @override
  String get btnSendKitchen => 'INVIA COMANDA';

  @override
  String get msgOrderSent => 'Comanda inviata!';

  @override
  String get msgChangesSaved => 'Modifiche salvate';

  @override
  String get msgChangesNotSaved => 'Modifiche non salvate';

  @override
  String get msgExitWithoutSaving => 'Vuoi uscire senza inviare la comanda?';

  @override
  String get headerKitchenFlow => '--- Flusso Cucina e Portate ---';

  @override
  String get btnFireCourse => 'DAI IL VIA';

  @override
  String msgCourseFired(String course) {
    return 'Richiesto \'Via\' per $course';
  }

  @override
  String get itemStatusPending => 'In Attesa';

  @override
  String get itemStatusFired => 'Inviato in cucina';

  @override
  String get itemStatusCooking => 'In Cottura';

  @override
  String get itemStatusReady => 'Pronto';

  @override
  String get itemStatusServed => 'Servito';

  @override
  String get badgeStatusInQueue => 'IN CODA';

  @override
  String get badgeStatusCooking => 'IN PREPARAZIONE';

  @override
  String get badgeStatusReady => 'PRONTO DA SERVIRE';

  @override
  String get badgeStatusCompleted => 'COMPLETATO';

  @override
  String get btnMarkServed => 'SERVI';

  @override
  String get labelNoOrders => 'Nessun ordine effettuato';

  @override
  String get headerBillPayment => '--- Conto e Pagamenti ---';

  @override
  String get actionQuickPay => 'Incasso Rapido';

  @override
  String get actionPayTotalDesc => 'Paga tutto senza dividere';

  @override
  String get actionSplitPay => 'Cassa / Divisione';

  @override
  String get actionSplitDesc => 'Gestisci pagamenti parziali';

  @override
  String dialogPaymentTable(String tableName) {
    return 'Incasso $tableName';
  }

  @override
  String get labelPaymentTotal => 'Totale da incassare';

  @override
  String get dialogSelectPaymentMethod => 'Seleziona metodo (Paga Tutto):';

  @override
  String get cardPayment => 'Carta';

  @override
  String get cashPayment => 'Contanti';

  @override
  String get billSplitEach => 'Per Piatto';

  @override
  String get billSplitEvenly => 'Alla Romana';

  @override
  String get selectToPay => 'Seleziona cosa pagare';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get unselectAll => 'Deseleziona tutto';

  @override
  String get allSelected => 'Tutto selezionato';

  @override
  String get labelSplitEvenlyDescription => 'In quante parti dividere?';

  @override
  String get totalPeople => 'Persone totali';

  @override
  String get labelPartsToPay => 'Quote da pagare ora:';

  @override
  String infoPartsPaying(int payingParts, int splitParts) {
    return '$payingParts quote su $splitParts';
  }

  @override
  String get labelSinglePart => 'Quota singola:';

  @override
  String get labelTotal => 'Totale';

  @override
  String infoTotalAmount(String total) {
    return 'Totale: $total';
  }

  @override
  String get labelToPay => 'DA PAGARE';

  @override
  String get labelRemaining => 'RIMANENTE';

  @override
  String infoPriceEach(String price) {
    return '$price cad.';
  }

  @override
  String get btnPay => 'PAGA';

  @override
  String get msgPaymentSuccess => 'Pagamento registrato';

  @override
  String get headerVoids => '--- Storni e Cancellazioni ---';

  @override
  String get titleVoidItem => 'Storno Piatto';

  @override
  String get titleVoidItemAction => 'Storna / Elimina';

  @override
  String get subtitleVoidItemAction => 'Rimuovi piatto dall\'ordine';

  @override
  String titleVoidItemDialog(String itemName) {
    return 'Elimina: $itemName';
  }

  @override
  String get labelVoidQuantity => 'Quantità da stornare:';

  @override
  String get labelVoidReasonPlaceholder => 'Motivazione:';

  @override
  String get dialogConfirmVoid => 'CONFERMA STORNO';

  @override
  String get labelRefundOption => 'Rimborsare l\'importo?';

  @override
  String get labelViewVoided => 'Vedi storni';

  @override
  String get labelNoVoidedItems => 'Nessuno storno registrato';

  @override
  String labelVoidedList(String tableName) {
    return 'Storico Storni $tableName';
  }

  @override
  String labelVoidReason(String reason, String hour, String minutes,
      String isRefunded, String statusWhenVoided) {
    String _temp0 = intl.Intl.selectLogic(
      isRefunded,
      {
        'false': 'Non Rimborsato, ',
        'true': 'Rimborsato, ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      statusWhenVoided,
      {
        'pending': 'In Attesa',
        'served': 'Servito',
        'cooking': 'In Cottura',
        'fired': 'Inviato in cucina',
        'ready': 'Pronto',
        'other': '',
      },
    );
    return 'Motivo: $reason\n$hour:$minutes\n$_temp0 $_temp1';
  }

  @override
  String get msgVoidItem => 'Piatto stornato correttamente';

  @override
  String get headerGeneral => '--- Etichette Generiche ---';

  @override
  String get labelAll => 'Tutti';

  @override
  String get dialogConfirm => 'CONFERMA';

  @override
  String get dialogCancel => 'Annulla';

  @override
  String get dialogSave => 'Salva';

  @override
  String get dialogEdit => 'Modifica';

  @override
  String get msgAttention => 'Attenzione';
}
