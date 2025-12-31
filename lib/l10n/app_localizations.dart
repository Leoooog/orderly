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

  /// No description provided for @adminAppName.
  ///
  /// In it, this message translates to:
  /// **'Orderly - Admin'**
  String get adminAppName;

  /// No description provided for @posAppName.
  ///
  /// In it, this message translates to:
  /// **'Orderly - Cassa'**
  String get posAppName;

  /// No description provided for @appName.
  ///
  /// In it, this message translates to:
  /// **'Orderly Pocket'**
  String get appName;

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

  /// No description provided for @navHistory.
  ///
  /// In it, this message translates to:
  /// **'AL TAVOLO'**
  String get navHistory;

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
  /// **'CUCINA'**
  String get tableStatusOrdered;

  /// No description provided for @tableStatusReady.
  ///
  /// In it, this message translates to:
  /// **'PRONTO'**
  String get tableStatusReady;

  /// No description provided for @tableStatusServed.
  ///
  /// In it, this message translates to:
  /// **'SERVITO'**
  String get tableStatusServed;

  /// No description provided for @actionMove.
  ///
  /// In it, this message translates to:
  /// **'Sposta Tavolo'**
  String get actionMove;

  /// No description provided for @actionMerge.
  ///
  /// In it, this message translates to:
  /// **'Unisci Tavolo'**
  String get actionMerge;

  /// No description provided for @actionQuickPay.
  ///
  /// In it, this message translates to:
  /// **'Incasso Rapido'**
  String get actionQuickPay;

  /// No description provided for @actionSplitPay.
  ///
  /// In it, this message translates to:
  /// **'Cassa / Divisione'**
  String get actionSplitPay;

  /// No description provided for @actionCancelTable.
  ///
  /// In it, this message translates to:
  /// **'Annulla Tavolo'**
  String get actionCancelTable;

  /// No description provided for @actionTransfer.
  ///
  /// In it, this message translates to:
  /// **'Trasferisci su un tavolo libero'**
  String get actionTransfer;

  /// No description provided for @actionMergeDesc.
  ///
  /// In it, this message translates to:
  /// **'Unisci a un tavolo occupato'**
  String get actionMergeDesc;

  /// No description provided for @actionPayTotalDesc.
  ///
  /// In it, this message translates to:
  /// **'Paga tutto senza dividere'**
  String get actionPayTotalDesc;

  /// No description provided for @actionSplitDesc.
  ///
  /// In it, this message translates to:
  /// **'Gestisci pagamenti parziali'**
  String get actionSplitDesc;

  /// No description provided for @actionResetDesc.
  ///
  /// In it, this message translates to:
  /// **'Reset senza incasso'**
  String get actionResetDesc;

  /// No description provided for @dialogOpenTable.
  ///
  /// In it, this message translates to:
  /// **'Apertura {tableName}'**
  String dialogOpenTable(String tableName);

  /// No description provided for @dialogCovers.
  ///
  /// In it, this message translates to:
  /// **'Quanti Coperti?'**
  String get dialogCovers;

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

  /// No description provided for @dialogConfirmVoid.
  ///
  /// In it, this message translates to:
  /// **'CONFERMA STORNO'**
  String get dialogConfirmVoid;

  /// No description provided for @btnOpen.
  ///
  /// In it, this message translates to:
  /// **'Apri Tavolo'**
  String get btnOpen;

  /// No description provided for @btnSendKitchen.
  ///
  /// In it, this message translates to:
  /// **'INVIA COMANDA'**
  String get btnSendKitchen;

  /// No description provided for @btnFireCourse.
  ///
  /// In it, this message translates to:
  /// **'DAI IL VIA'**
  String get btnFireCourse;

  /// No description provided for @btnPay.
  ///
  /// In it, this message translates to:
  /// **'PAGA'**
  String get btnPay;

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

  /// No description provided for @labelNotes.
  ///
  /// In it, this message translates to:
  /// **'Note Cucina'**
  String get labelNotes;

  /// No description provided for @labelSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca prodotto...'**
  String get labelSearch;

  /// No description provided for @labelTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get labelTotal;

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

  /// No description provided for @labelSelectAll.
  ///
  /// In it, this message translates to:
  /// **'Seleziona Tutto'**
  String get labelSelectAll;

  /// No description provided for @labelDeselectAll.
  ///
  /// In it, this message translates to:
  /// **'Deseleziona Tutto'**
  String get labelDeselectAll;

  /// No description provided for @msgPaymentSuccess.
  ///
  /// In it, this message translates to:
  /// **'Pagamento registrato'**
  String get msgPaymentSuccess;

  /// No description provided for @msgOrderSent.
  ///
  /// In it, this message translates to:
  /// **'Comanda inviata'**
  String get msgOrderSent;

  /// No description provided for @msgChangesSaved.
  ///
  /// In it, this message translates to:
  /// **'Modifiche salvate'**
  String get msgChangesSaved;
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
