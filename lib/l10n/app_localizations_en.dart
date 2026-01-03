// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get headerAppMetadata => '--- Titles and General Info ---';

  @override
  String get appName => 'Orderly Pocket';

  @override
  String get waiterAppName => 'Orderly - Waiter';

  @override
  String get kitchenAppName => 'Orderly - Kitchen';

  @override
  String get posAppName => 'Orderly - POS';

  @override
  String get adminAppName => 'Orderly - Admin';

  @override
  String get headerAuth => '--- Authentication ---';

  @override
  String get loginInsertPin => 'Enter Waiter PIN';

  @override
  String get loginPinError => 'Wrong PIN';

  @override
  String get headerNavigation => '--- Navigation ---';

  @override
  String get navTables => 'Hall';

  @override
  String get navMenu => 'MENU';

  @override
  String get navTableHistory => 'AT TABLE';

  @override
  String get msgBack => 'Back';

  @override
  String get exit => 'Exit';

  @override
  String get headerTableStatus => '--- Table Status (Logic) ---';

  @override
  String get tableStatusFree => 'FREE';

  @override
  String get tableStatusSeated => 'WAITING';

  @override
  String get tableStatusOrdered => 'ORDERED';

  @override
  String get tableStatusReady => 'READY';

  @override
  String get tableStatusEating => 'SERVED';

  @override
  String get headerTableActions => '--- Table Management (Hall) ---';

  @override
  String tableActions(String tableName) {
    return 'Actions for Table $tableName';
  }

  @override
  String tableName(String tableName) {
    return 'Table $tableName';
  }

  @override
  String dialogOpenTable(String tableName) {
    return 'Opening $tableName';
  }

  @override
  String get btnOpen => 'Open Table';

  @override
  String get dialogGuests => 'How many guests?';

  @override
  String labelGuests(int guests) {
    return 'Guests: $guests';
  }

  @override
  String get actionMove => 'Move Table';

  @override
  String get actionTransfer => 'Transfer to a free table';

  @override
  String get dialogMoveTable => 'Move to...';

  @override
  String get actionMerge => 'Merge Table';

  @override
  String get actionMergeDesc => 'Merge with an occupied table';

  @override
  String get dialogMergeTable => 'Merge with...';

  @override
  String get actionCancelTable => 'Void Table';

  @override
  String get actionResetDesc => 'Close table without payment';

  @override
  String msgConfirmCancelTable(String tableName) {
    return 'You are about to void table $tableName.\n\nAll current orders will be lost and the table will become free without recording revenue.\n\nAre you sure?';
  }

  @override
  String msgTableOpened(String tableName) {
    return 'Table $tableName opened';
  }

  @override
  String get tableMoved => 'Table moved successfully';

  @override
  String get tableMerged => 'Tables merged successfully';

  @override
  String get tableReset => 'Table voided and reset';

  @override
  String get msgNoTablesAvailable => 'No tables available';

  @override
  String get headerMenuCart => '--- Menu and Cart ---';

  @override
  String get labelSearch => 'Search product...';

  @override
  String get labelNoProducts => 'No products found';

  @override
  String get labelIngredients => 'INGREDIENTS';

  @override
  String get labelAllergens => 'ALLERGENS';

  @override
  String get cartSheetTitle => 'Order';

  @override
  String cartSheetItemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String cartEditingItem(String itemName) {
    return 'Editing: $itemName';
  }

  @override
  String get msgMenuItemNotFound => 'Menu item not found';

  @override
  String get cartEditingQuantity => 'How many dishes do you want to edit?';

  @override
  String get dialogMoveToCourse => 'Move to:';

  @override
  String get labelExtras => 'Add-ons (Extras):';

  @override
  String get labelNotesTitle => 'Kitchen Notes';

  @override
  String get fieldNotesPlaceholder => 'Ex. No onion...';

  @override
  String get btnEdit => 'EDIT';

  @override
  String get labelEdit => 'Edit';

  @override
  String get subtitleEditItemAction => 'Change notes or variants';

  @override
  String get btnSendKitchen => 'SEND ORDER';

  @override
  String get msgOrderSent => 'Order sent!';

  @override
  String get msgChangesSaved => 'Changes saved';

  @override
  String get msgChangesNotSaved => 'Changes not saved';

  @override
  String get msgExitWithoutSaving =>
      'Do you want to exit without sending the order? \nAll changes will be lost.';

  @override
  String get headerKitchenFlow => '--- Kitchen Flow and Courses ---';

  @override
  String get btnFireCourse => 'FIRE COURSE';

  @override
  String msgCourseFired(String course) {
    return '\'Fire\' requested for $course';
  }

  @override
  String get itemStatusPending => 'Pending';

  @override
  String get itemStatusFired => 'Sent to kitchen';

  @override
  String get itemStatusCooking => 'Cooking';

  @override
  String get itemStatusReady => 'Ready';

  @override
  String get itemStatusServed => 'Served';

  @override
  String get itemStatusUnknown => 'Unknown';

  @override
  String get badgeStatusInQueue => 'IN QUEUE';

  @override
  String get badgeStatusCooking => 'PREPARING';

  @override
  String get badgeStatusReady => 'READY TO SERVE';

  @override
  String get badgeStatusCompleted => 'COMPLETED';

  @override
  String get btnMarkServed => 'SERVE';

  @override
  String get labelNoOrders => 'No orders placed';

  @override
  String get headerBillPayment => '--- Bill and Payments ---';

  @override
  String get actionQuickPay => 'Quick Pay';

  @override
  String get actionPayTotalDesc => 'Pay full amount without splitting';

  @override
  String get actionSplitPay => 'Cashier / Split';

  @override
  String get actionSplitDesc => 'Manage partial payments';

  @override
  String dialogPaymentTable(String tableName) {
    return 'Payment $tableName';
  }

  @override
  String get labelPaymentTotal => 'Total to pay';

  @override
  String get dialogSelectPaymentMethod => 'Select method (Pay All):';

  @override
  String get cardPayment => 'Card';

  @override
  String get cashPayment => 'Cash';

  @override
  String get billSplitEach => 'By Item';

  @override
  String get billSplitEvenly => 'Even Split';

  @override
  String get selectToPay => 'Select what to pay';

  @override
  String get selectAll => 'Select All';

  @override
  String get unselectAll => 'Deselect All';

  @override
  String get allSelected => 'All selected';

  @override
  String get labelSplitEvenlyDescription => 'In how many parts to split?';

  @override
  String get totalPeople => 'Total people';

  @override
  String get labelPartsToPay => 'Shares to pay now:';

  @override
  String infoPartsPaying(int payingParts, int splitParts) {
    return '$payingParts shares out of $splitParts';
  }

  @override
  String get labelSinglePart => 'Single share:';

  @override
  String get labelTotal => 'Total';

  @override
  String infoTotalAmount(String total) {
    return 'Total: $total';
  }

  @override
  String get labelToPay => 'TO PAY';

  @override
  String get labelRemaining => 'REMAINING';

  @override
  String infoPriceEach(String price) {
    return '$price each';
  }

  @override
  String get titleTenantSelection => 'Inserisci il tuo codice locale';

  @override
  String get fieldTenantPlaceholder => 'Es. ristorante-123 o 192.168.1.100';

  @override
  String get tenantSelectionDevHelper =>
      'Inserisci l\'indirizzo IP del server locale';

  @override
  String get btnTenantSelection => 'SELEZIONA LOCALE';

  @override
  String get btnPay => 'PAY';

  @override
  String get msgPaymentSuccess => 'Payment recorded';

  @override
  String get headerVoids => '--- Voids and Cancellations ---';

  @override
  String get titleVoidItem => 'Void Item';

  @override
  String get titleVoidItemAction => 'Void / Delete';

  @override
  String get subtitleVoidItemAction => 'Remove dish from order';

  @override
  String titleVoidItemDialog(String itemName) {
    return 'Delete: $itemName';
  }

  @override
  String get labelVoidQuantity => 'Quantity to void:';

  @override
  String get labelVoidReasonPlaceholder => 'Reason:';

  @override
  String get dialogConfirmVoid => 'CONFIRM VOID';

  @override
  String get labelRefundOption => 'Refund the amount?';

  @override
  String get labelViewVoided => 'View voids';

  @override
  String get labelNoVoidedItems => 'No voids recorded';

  @override
  String labelVoidedList(String tableName) {
    return 'Void History $tableName';
  }

  @override
  String labelVoidReason(String reason, String hour, String minutes,
      String isRefunded, String statusWhenVoided) {
    String _temp0 = intl.Intl.selectLogic(
      isRefunded,
      {
        'false': 'Not Refunded, ',
        'true': 'Refunded, ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      statusWhenVoided,
      {
        'pending': 'Pending',
        'served': 'Served',
        'cooking': 'Cooking',
        'fired': 'Sent to kitchen',
        'ready': 'Ready',
        'other': '',
      },
    );
    return 'Reason: $reason\n$hour:$minutes\n$_temp0 $_temp1';
  }

  @override
  String get msgVoidItem => 'Item voided successfully';

  @override
  String get headerGeneral => '--- General Labels ---';

  @override
  String get labelAll => 'All';

  @override
  String get dialogConfirm => 'CONFIRM';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogEdit => 'Edit';

  @override
  String get msgAttention => 'Attention';

  @override
  String get labelRemoveIngredients => 'Remove Ingredients';

  @override
  String get subtitleRemoveIngredients => 'Select ingredients to remove';
}
