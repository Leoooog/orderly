import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @headerAppMetadata.
  ///
  /// In it, this message translates to:
  /// **'--- Titoli e Info Generali ---'**
  String get headerAppMetadata;

  /// No description provided for @appName.
  ///
  /// In it, this message translates to:
  /// **'Orderly Pocket'**
  String get appName;

  /// No description provided for @waiterAppName.
  ///
  /// In it, this message translates to:
  /// **'Orderly - Sala'**
  String get waiterAppName;

  /// No description provided for @kitchenAppName.
  ///
  /// In it, this message translates to:
  /// **'Orderly - Cucina'**
  String get kitchenAppName;

  /// No description provided for @posAppName.
  ///
  /// In it, this message translates to:
  /// **'Orderly - Cassa'**
  String get posAppName;

  /// No description provided for @adminAppName.
  ///
  /// In it, this message translates to:
  /// **'Orderly - Admin'**
  String get adminAppName;

  /// No description provided for @headerAuth.
  ///
  /// In it, this message translates to:
  /// **'--- Autenticazione ---'**
  String get headerAuth;

  /// No description provided for @loginInsertPin.
  ///
  /// In it, this message translates to:
  /// **'Inserisci PIN Cameriere'**
  String get loginInsertPin;

  /// No description provided for @loginPinError.
  ///
  /// In it, this message translates to:
  /// **'PIN Errato'**
  String get loginPinError;

  /// No description provided for @headerNavigation.
  ///
  /// In it, this message translates to:
  /// **'--- Navigazione ---'**
  String get headerNavigation;

  /// No description provided for @navTables.
  ///
  /// In it, this message translates to:
  /// **'Sala'**
  String get navTables;

  /// No description provided for @navMenu.
  ///
  /// In it, this message translates to:
  /// **'MENU'**
  String get navMenu;

  /// No description provided for @navTableHistory.
  ///
  /// In it, this message translates to:
  /// **'AL TAVOLO'**
  String get navTableHistory;

  /// No description provided for @msgBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get msgBack;

  /// No description provided for @exit.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get exit;

  /// No description provided for @headerTableStatus.
  ///
  /// In it, this message translates to:
  /// **'--- Stati del Tavolo (Logica) ---'**
  String get headerTableStatus;

  /// No description provided for @tableStatusFree.
  ///
  /// In it, this message translates to:
  /// **'LIBERO'**
  String get tableStatusFree;

  /// No description provided for @tableStatusSeated.
  ///
  /// In it, this message translates to:
  /// **'ATTESA'**
  String get tableStatusSeated;

  /// No description provided for @tableStatusOrdered.
  ///
  /// In it, this message translates to:
  /// **'ORDINATO'**
  String get tableStatusOrdered;

  /// No description provided for @tableStatusReady.
  ///
  /// In it, this message translates to:
  /// **'PRONTO'**
  String get tableStatusReady;

  /// No description provided for @tableStatusEating.
  ///
  /// In it, this message translates to:
  /// **'SERVITO'**
  String get tableStatusEating;

  /// No description provided for @headerTableActions.
  ///
  /// In it, this message translates to:
  /// **'--- Gestione Tavoli (Sala) ---'**
  String get headerTableActions;

  /// No description provided for @tableActions.
  ///
  /// In it, this message translates to:
  /// **'Azioni Tavolo {tableName}'**
  String tableActions(String tableName);

  /// No description provided for @tableName.
  ///
  /// In it, this message translates to:
  /// **'Tavolo {tableName}'**
  String tableName(String tableName);

  /// No description provided for @dialogOpenTable.
  ///
  /// In it, this message translates to:
  /// **'Apertura {tableName}'**
  String dialogOpenTable(String tableName);

  /// No description provided for @btnOpen.
  ///
  /// In it, this message translates to:
  /// **'Apri Tavolo'**
  String get btnOpen;

  /// No description provided for @dialogGuests.
  ///
  /// In it, this message translates to:
  /// **'Quanti Coperti?'**
  String get dialogGuests;

  /// No description provided for @labelGuests.
  ///
  /// In it, this message translates to:
  /// **'Coperti: {guests}'**
  String labelGuests(int guests);

  /// No description provided for @actionMove.
  ///
  /// In it, this message translates to:
  /// **'Sposta Tavolo'**
  String get actionMove;

  /// No description provided for @actionTransfer.
  ///
  /// In it, this message translates to:
  /// **'Trasferisci su un tavolo libero'**
  String get actionTransfer;

  /// No description provided for @dialogMoveTable.
  ///
  /// In it, this message translates to:
  /// **'Sposta su...'**
  String get dialogMoveTable;

  /// No description provided for @actionMerge.
  ///
  /// In it, this message translates to:
  /// **'Unisci Tavolo'**
  String get actionMerge;

  /// No description provided for @actionMergeDesc.
  ///
  /// In it, this message translates to:
  /// **'Unisci a un tavolo occupato'**
  String get actionMergeDesc;

  /// No description provided for @dialogMergeTable.
  ///
  /// In it, this message translates to:
  /// **'Unisci a...'**
  String get dialogMergeTable;

  /// No description provided for @actionCancelTable.
  ///
  /// In it, this message translates to:
  /// **'Annulla Tavolo'**
  String get actionCancelTable;

  /// No description provided for @actionResetDesc.
  ///
  /// In it, this message translates to:
  /// **'Chiudi tavolo senza incasso'**
  String get actionResetDesc;

  /// No description provided for @msgConfirmCancelTable.
  ///
  /// In it, this message translates to:
  /// **'Stai per annullare il tavolo {tableName}.\n\nTutti gli ordini correnti verranno persi e il tavolo tornerà libero senza registrare incasso.\n\nSei sicuro?'**
  String msgConfirmCancelTable(String tableName);

  /// No description provided for @msgTableOpened.
  ///
  /// In it, this message translates to:
  /// **'Tavolo {tableName} aperto'**
  String msgTableOpened(String tableName);

  /// No description provided for @tableMoved.
  ///
  /// In it, this message translates to:
  /// **'Tavolo spostato con successo'**
  String get tableMoved;

  /// No description provided for @tableMerged.
  ///
  /// In it, this message translates to:
  /// **'Tavoli uniti con successo'**
  String get tableMerged;

  /// No description provided for @tableReset.
  ///
  /// In it, this message translates to:
  /// **'Tavolo annullato e resettato'**
  String get tableReset;

  /// No description provided for @msgNoTablesAvailable.
  ///
  /// In it, this message translates to:
  /// **'Nessun tavolo disponibile'**
  String get msgNoTablesAvailable;

  /// No description provided for @headerMenuCart.
  ///
  /// In it, this message translates to:
  /// **'--- Menu e Carrello ---'**
  String get headerMenuCart;

  /// No description provided for @labelSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca prodotto...'**
  String get labelSearch;

  /// No description provided for @labelNoProducts.
  ///
  /// In it, this message translates to:
  /// **'Nessun prodotto trovato'**
  String get labelNoProducts;

  /// No description provided for @labelIngredients.
  ///
  /// In it, this message translates to:
  /// **'INGREDIENTI'**
  String get labelIngredients;

  /// No description provided for @labelAllergens.
  ///
  /// In it, this message translates to:
  /// **'ALLERGENI'**
  String get labelAllergens;

  /// No description provided for @cartSheetTitle.
  ///
  /// In it, this message translates to:
  /// **'Comanda'**
  String get cartSheetTitle;

  /// No description provided for @cartSheetItemsCountLabel.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessun articolo} =1{1 articolo} other{{count} articoli}}'**
  String cartSheetItemsCountLabel(int count);

  /// No description provided for @cartEditingItem.
  ///
  /// In it, this message translates to:
  /// **'Stai modificando: {itemName}'**
  String cartEditingItem(String itemName);

  /// No description provided for @cartEditingQuantity.
  ///
  /// In it, this message translates to:
  /// **'Quanti piatti vuoi modificare?'**
  String get cartEditingQuantity;

  /// No description provided for @dialogMoveToCourse.
  ///
  /// In it, this message translates to:
  /// **'Sposta in:'**
  String get dialogMoveToCourse;

  /// No description provided for @labelExtras.
  ///
  /// In it, this message translates to:
  /// **'Aggiunte (Extra):'**
  String get labelExtras;

  /// No description provided for @labelNotesTitle.
  ///
  /// In it, this message translates to:
  /// **'Note Cucina'**
  String get labelNotesTitle;

  /// No description provided for @fieldNotesPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Es. No cipolla...'**
  String get fieldNotesPlaceholder;

  /// No description provided for @btnEdit.
  ///
  /// In it, this message translates to:
  /// **'MODIFICA'**
  String get btnEdit;

  /// No description provided for @labelEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get labelEdit;

  /// No description provided for @subtitleEditItemAction.
  ///
  /// In it, this message translates to:
  /// **'Cambia note o varianti'**
  String get subtitleEditItemAction;

  /// No description provided for @btnSendKitchen.
  ///
  /// In it, this message translates to:
  /// **'INVIA COMANDA'**
  String get btnSendKitchen;

  /// No description provided for @msgOrderSent.
  ///
  /// In it, this message translates to:
  /// **'Comanda inviata!'**
  String get msgOrderSent;

  /// No description provided for @msgChangesSaved.
  ///
  /// In it, this message translates to:
  /// **'Modifiche salvate'**
  String get msgChangesSaved;

  /// No description provided for @msgChangesNotSaved.
  ///
  /// In it, this message translates to:
  /// **'Modifiche non salvate'**
  String get msgChangesNotSaved;

  /// No description provided for @msgExitWithoutSaving.
  ///
  /// In it, this message translates to:
  /// **'Vuoi uscire senza inviare la comanda?'**
  String get msgExitWithoutSaving;

  /// No description provided for @headerKitchenFlow.
  ///
  /// In it, this message translates to:
  /// **'--- Flusso Cucina e Portate ---'**
  String get headerKitchenFlow;

  /// No description provided for @btnFireCourse.
  ///
  /// In it, this message translates to:
  /// **'DAI IL VIA'**
  String get btnFireCourse;

  /// No description provided for @msgCourseFired.
  ///
  /// In it, this message translates to:
  /// **'Richiesto \'Via\' per {course}'**
  String msgCourseFired(String course);

  /// No description provided for @itemStatusPending.
  ///
  /// In it, this message translates to:
  /// **'In Attesa'**
  String get itemStatusPending;

  /// No description provided for @itemStatusFired.
  ///
  /// In it, this message translates to:
  /// **'Inviato in cucina'**
  String get itemStatusFired;

  /// No description provided for @itemStatusCooking.
  ///
  /// In it, this message translates to:
  /// **'In Cottura'**
  String get itemStatusCooking;

  /// No description provided for @itemStatusReady.
  ///
  /// In it, this message translates to:
  /// **'Pronto'**
  String get itemStatusReady;

  /// No description provided for @itemStatusServed.
  ///
  /// In it, this message translates to:
  /// **'Servito'**
  String get itemStatusServed;

  /// No description provided for @badgeStatusInQueue.
  ///
  /// In it, this message translates to:
  /// **'IN CODA'**
  String get badgeStatusInQueue;

  /// No description provided for @badgeStatusCooking.
  ///
  /// In it, this message translates to:
  /// **'IN PREPARAZIONE'**
  String get badgeStatusCooking;

  /// No description provided for @badgeStatusReady.
  ///
  /// In it, this message translates to:
  /// **'PRONTO DA SERVIRE'**
  String get badgeStatusReady;

  /// No description provided for @badgeStatusCompleted.
  ///
  /// In it, this message translates to:
  /// **'COMPLETATO'**
  String get badgeStatusCompleted;

  /// No description provided for @btnMarkServed.
  ///
  /// In it, this message translates to:
  /// **'SERVI'**
  String get btnMarkServed;

  /// No description provided for @labelNoOrders.
  ///
  /// In it, this message translates to:
  /// **'Nessun ordine effettuato'**
  String get labelNoOrders;

  /// No description provided for @headerBillPayment.
  ///
  /// In it, this message translates to:
  /// **'--- Conto e Pagamenti ---'**
  String get headerBillPayment;

  /// No description provided for @actionQuickPay.
  ///
  /// In it, this message translates to:
  /// **'Incasso Rapido'**
  String get actionQuickPay;

  /// No description provided for @actionPayTotalDesc.
  ///
  /// In it, this message translates to:
  /// **'Paga tutto senza dividere'**
  String get actionPayTotalDesc;

  /// No description provided for @actionSplitPay.
  ///
  /// In it, this message translates to:
  /// **'Cassa / Divisione'**
  String get actionSplitPay;

  /// No description provided for @actionSplitDesc.
  ///
  /// In it, this message translates to:
  /// **'Gestisci pagamenti parziali'**
  String get actionSplitDesc;

  /// No description provided for @dialogPaymentTable.
  ///
  /// In it, this message translates to:
  /// **'Incasso {tableName}'**
  String dialogPaymentTable(String tableName);

  /// No description provided for @labelPaymentTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale da incassare'**
  String get labelPaymentTotal;

  /// No description provided for @dialogSelectPaymentMethod.
  ///
  /// In it, this message translates to:
  /// **'Seleziona metodo (Paga Tutto):'**
  String get dialogSelectPaymentMethod;

  /// No description provided for @cardPayment.
  ///
  /// In it, this message translates to:
  /// **'Carta'**
  String get cardPayment;

  /// No description provided for @cashPayment.
  ///
  /// In it, this message translates to:
  /// **'Contanti'**
  String get cashPayment;

  /// No description provided for @billSplitEach.
  ///
  /// In it, this message translates to:
  /// **'Per Piatto'**
  String get billSplitEach;

  /// No description provided for @billSplitEvenly.
  ///
  /// In it, this message translates to:
  /// **'Alla Romana'**
  String get billSplitEvenly;

  /// No description provided for @selectToPay.
  ///
  /// In it, this message translates to:
  /// **'Seleziona cosa pagare'**
  String get selectToPay;

  /// No description provided for @selectAll.
  ///
  /// In it, this message translates to:
  /// **'Seleziona tutto'**
  String get selectAll;

  /// No description provided for @unselectAll.
  ///
  /// In it, this message translates to:
  /// **'Deseleziona tutto'**
  String get unselectAll;

  /// No description provided for @allSelected.
  ///
  /// In it, this message translates to:
  /// **'Tutto selezionato'**
  String get allSelected;

  /// No description provided for @labelSplitEvenlyDescription.
  ///
  /// In it, this message translates to:
  /// **'In quante parti dividere?'**
  String get labelSplitEvenlyDescription;

  /// No description provided for @totalPeople.
  ///
  /// In it, this message translates to:
  /// **'Persone totali'**
  String get totalPeople;

  /// No description provided for @labelPartsToPay.
  ///
  /// In it, this message translates to:
  /// **'Quote da pagare ora:'**
  String get labelPartsToPay;

  /// No description provided for @infoPartsPaying.
  ///
  /// In it, this message translates to:
  /// **'{payingParts} quote su {splitParts}'**
  String infoPartsPaying(int payingParts, int splitParts);

  /// No description provided for @labelSinglePart.
  ///
  /// In it, this message translates to:
  /// **'Quota singola:'**
  String get labelSinglePart;

  /// No description provided for @labelTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get labelTotal;

  /// No description provided for @infoTotalAmount.
  ///
  /// In it, this message translates to:
  /// **'Totale: {total}'**
  String infoTotalAmount(String total);

  /// No description provided for @labelToPay.
  ///
  /// In it, this message translates to:
  /// **'DA PAGARE'**
  String get labelToPay;

  /// No description provided for @labelRemaining.
  ///
  /// In it, this message translates to:
  /// **'RIMANENTE'**
  String get labelRemaining;

  /// No description provided for @infoPriceEach.
  ///
  /// In it, this message translates to:
  /// **'{price} cad.'**
  String infoPriceEach(String price);

  /// No description provided for @btnPay.
  ///
  /// In it, this message translates to:
  /// **'PAGA'**
  String get btnPay;

  /// No description provided for @msgPaymentSuccess.
  ///
  /// In it, this message translates to:
  /// **'Pagamento registrato'**
  String get msgPaymentSuccess;

  /// No description provided for @headerVoids.
  ///
  /// In it, this message translates to:
  /// **'--- Storni e Cancellazioni ---'**
  String get headerVoids;

  /// No description provided for @titleVoidItem.
  ///
  /// In it, this message translates to:
  /// **'Storno Piatto'**
  String get titleVoidItem;

  /// No description provided for @titleVoidItemAction.
  ///
  /// In it, this message translates to:
  /// **'Storna / Elimina'**
  String get titleVoidItemAction;

  /// No description provided for @subtitleVoidItemAction.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi piatto dall\'ordine'**
  String get subtitleVoidItemAction;

  /// No description provided for @titleVoidItemDialog.
  ///
  /// In it, this message translates to:
  /// **'Elimina: {itemName}'**
  String titleVoidItemDialog(String itemName);

  /// No description provided for @labelVoidQuantity.
  ///
  /// In it, this message translates to:
  /// **'Quantità da stornare:'**
  String get labelVoidQuantity;

  /// No description provided for @labelVoidReasonPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Motivazione:'**
  String get labelVoidReasonPlaceholder;

  /// No description provided for @dialogConfirmVoid.
  ///
  /// In it, this message translates to:
  /// **'CONFERMA STORNO'**
  String get dialogConfirmVoid;

  /// No description provided for @labelRefundOption.
  ///
  /// In it, this message translates to:
  /// **'Rimborsare l\'importo?'**
  String get labelRefundOption;

  /// No description provided for @labelViewVoided.
  ///
  /// In it, this message translates to:
  /// **'Vedi storni'**
  String get labelViewVoided;

  /// No description provided for @labelNoVoidedItems.
  ///
  /// In it, this message translates to:
  /// **'Nessuno storno registrato'**
  String get labelNoVoidedItems;

  /// No description provided for @labelVoidedList.
  ///
  /// In it, this message translates to:
  /// **'Storico Storni {tableName}'**
  String labelVoidedList(String tableName);

  /// No description provided for @labelVoidReason.
  ///
  /// In it, this message translates to:
  /// **'Motivo: {reason}\n{hour}:{minutes}\n{isRefunded, select, false{Non Rimborsato, } true{Rimborsato, } other{}} {statusWhenVoided, select, pending{In Attesa} served{Servito} cooking{In Cottura} fired{Inviato in cucina} ready{Pronto} other{}}'**
  String labelVoidReason(String reason, String hour, String minutes,
      String isRefunded, String statusWhenVoided);

  /// No description provided for @msgVoidItem.
  ///
  /// In it, this message translates to:
  /// **'Piatto stornato correttamente'**
  String get msgVoidItem;

  /// No description provided for @headerGeneral.
  ///
  /// In it, this message translates to:
  /// **'--- Etichette Generiche ---'**
  String get headerGeneral;

  /// No description provided for @labelAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get labelAll;

  /// No description provided for @dialogConfirm.
  ///
  /// In it, this message translates to:
  /// **'CONFERMA'**
  String get dialogConfirm;

  /// No description provided for @dialogCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get dialogCancel;

  /// No description provided for @dialogSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get dialogSave;

  /// No description provided for @dialogEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get dialogEdit;

  /// No description provided for @msgAttention.
  ///
  /// In it, this message translates to:
  /// **'Attenzione'**
  String get msgAttention;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
