import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Auth
      'app_name': 'NFC Wallet',
      'app_tagline': 'Secure payments at your fingertips',
      'login': 'Login',
      'signup': 'Sign Up',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'confirm_password': 'Confirm Password',
      'dont_have_account': "Don't have an account? ",
      'already_have_account': 'Already have an account? ',
      'create_account': 'Create Account',
      'sign_up_tagline': 'Sign up to get started',
      'demo_login_hint': 'Demo: Use any email and password to login',
      'demo_signup_hint': 'Demo: Any valid input will create an account',
      
      // Dashboard
      'available_balance': 'Available Balance',
      'active': 'Active',
      'quick_actions': 'Quick Actions',
      'pay_with_nfc': 'Pay with NFC',
      'receive_payment': 'Receive Payment',
      'nfc_available': 'NFC Available',
      'nfc_unavailable': 'NFC Unavailable',
      'nfc_unknown': 'NFC Status Unknown',
      'checking_nfc': 'Checking NFC...',
      'recent_transactions': 'Recent Transactions',
      'view_all': 'View All',
      
      // Transactions
      'payment_received': 'Payment Received',
      'payment_sent': 'Payment Sent',
      'wallet_topup': 'Wallet Top-up',
      'nfc_payment': 'NFC Payment',
      'bank_transfer': 'Bank Transfer',
      
      // Pay Screen
      'virtual_card': 'Virtual Card',
      'cardholder': 'CARDHOLDER',
      'expires': 'EXPIRES',
      'enable_payment_mode': 'Enable Payment Mode',
      'cancel_payment': 'Cancel Payment',
      'ready_to_pay': 'Ready to Pay',
      'activating': 'Activating...',
      'tap_to_enable': 'Tap to Enable',
      'ready_to_pay_desc': 'Hold your phone near the payment terminal to complete the transaction.',
      'activating_desc': 'Please wait while we prepare your payment.',
      'tap_to_enable_desc': 'Tap the button above to activate NFC payment mode, then hold your phone near a payment terminal.',
      
      // Receive Screen
      'enter_amount': 'Enter Amount',
      'enter_amount_desc': 'Enter the amount to receive from customer',
      'quick_select': 'Quick Select',
      'start_receiving': 'Start Receiving',
      'waiting_for_customer': 'Waiting for Customer',
      'amount': 'Amount',
      'ask_customer_tap': 'Ask customer to tap their NFC-enabled phone or card',
      'cancel': 'Cancel',
      'payment_received_title': 'Payment Received!',
      'token': 'Token',
      'done': 'Done',
      
      // Transaction History
      'transaction_history': 'Transaction History',
      'this_month': 'This Month',
      'received': 'Received',
      'sent': 'Sent',
      'all': 'All',
      'top_up': 'Top-up',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'this_week': 'This Week',
      
      // Settings
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
    },
    'ar': {
      // Auth
      'app_name': 'محفظة NFC',
      'app_tagline': 'مدفوعات آمنة في متناول يدك',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'confirm_password': 'تأكيد كلمة المرور',
      'dont_have_account': 'ليس لديك حساب؟ ',
      'already_have_account': 'لديك حساب بالفعل؟ ',
      'create_account': 'إنشاء حساب',
      'sign_up_tagline': 'سجل للبدء',
      'demo_login_hint': 'تجريبي: استخدم أي بريد إلكتروني وكلمة مرور لتسجيل الدخول',
      'demo_signup_hint': 'تجريبي: أي إدخال صالح سينشئ حسابًا',
      
      // Dashboard
      'available_balance': 'الرصيد المتاح',
      'active': 'نشط',
      'quick_actions': 'إجراءات سريعة',
      'pay_with_nfc': 'الدفع عبر NFC',
      'receive_payment': 'استلام الدفع',
      'nfc_available': 'NFC متاح',
      'nfc_unavailable': 'NFC غير متاح',
      'nfc_unknown': 'حالة NFC غير معروفة',
      'checking_nfc': 'جاري فحص NFC...',
      'recent_transactions': 'المعاملات الأخيرة',
      'view_all': 'عرض الكل',
      
      // Transactions
      'payment_received': 'تم استلام الدفع',
      'payment_sent': 'تم إرسال الدفع',
      'wallet_topup': 'شحن المحفظة',
      'nfc_payment': 'دفع NFC',
      'bank_transfer': 'تحويل بنكي',
      
      // Pay Screen
      'virtual_card': 'بطاقة افتراضية',
      'cardholder': 'حامل البطاقة',
      'expires': 'تنتهي',
      'enable_payment_mode': 'تفعيل وضع الدفع',
      'cancel_payment': 'إلغاء الدفع',
      'ready_to_pay': 'جاهز للدفع',
      'activating': 'جاري التفعيل...',
      'tap_to_enable': 'اضغط للتفعيل',
      'ready_to_pay_desc': 'قرب هاتفك من طرفية الدفع لإتمام المعاملة.',
      'activating_desc': 'يرجى الانتظار بينما نجهز دفعتك.',
      'tap_to_enable_desc': 'اضغط على الزر أعلاه لتفعيل وضع الدفع عبر NFC، ثم قرب هاتفك من طرفية الدفع.',
      
      // Receive Screen
      'enter_amount': 'أدخل المبلغ',
      'enter_amount_desc': 'أدخل المبلغ المراد استلامه من العميل',
      'quick_select': 'اختيار سريع',
      'start_receiving': 'بدء الاستلام',
      'waiting_for_customer': 'في انتظار العميل',
      'amount': 'المبلغ',
      'ask_customer_tap': 'اطلب من العميل تقريب هاتفه أو بطاقته المزودة بـ NFC',
      'cancel': 'إلغاء',
      'payment_received_title': 'تم استلام الدفع!',
      'token': 'الرمز',
      'done': 'تم',
      
      // Transaction History
      'transaction_history': 'سجل المعاملات',
      'this_month': 'هذا الشهر',
      'received': 'المستلم',
      'sent': 'المرسل',
      'all': 'الكل',
      'top_up': 'شحن',
      'today': 'اليوم',
      'yesterday': 'أمس',
      'this_week': 'هذا الأسبوع',
      
      // Settings
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get appTagline => translate('app_tagline');
  String get login => translate('login');
  String get signup => translate('signup');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get fullName => translate('full_name');
  String get confirmPassword => translate('confirm_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get createAccount => translate('create_account');
  String get signUpTagline => translate('sign_up_tagline');
  String get demoLoginHint => translate('demo_login_hint');
  String get demoSignupHint => translate('demo_signup_hint');
  
  String get availableBalance => translate('available_balance');
  String get active => translate('active');
  String get quickActions => translate('quick_actions');
  String get payWithNfc => translate('pay_with_nfc');
  String get receivePayment => translate('receive_payment');
  String get nfcAvailable => translate('nfc_available');
  String get nfcUnavailable => translate('nfc_unavailable');
  String get nfcUnknown => translate('nfc_unknown');
  String get checkingNfc => translate('checking_nfc');
  String get recentTransactions => translate('recent_transactions');
  String get viewAll => translate('view_all');
  
  String get paymentReceived => translate('payment_received');
  String get paymentSent => translate('payment_sent');
  String get walletTopup => translate('wallet_topup');
  String get nfcPayment => translate('nfc_payment');
  String get bankTransfer => translate('bank_transfer');
  
  String get virtualCard => translate('virtual_card');
  String get cardholder => translate('cardholder');
  String get expires => translate('expires');
  String get enablePaymentMode => translate('enable_payment_mode');
  String get cancelPayment => translate('cancel_payment');
  String get readyToPay => translate('ready_to_pay');
  String get activating => translate('activating');
  String get tapToEnable => translate('tap_to_enable');
  String get readyToPayDesc => translate('ready_to_pay_desc');
  String get activatingDesc => translate('activating_desc');
  String get tapToEnableDesc => translate('tap_to_enable_desc');
  
  String get enterAmount => translate('enter_amount');
  String get enterAmountDesc => translate('enter_amount_desc');
  String get quickSelect => translate('quick_select');
  String get startReceiving => translate('start_receiving');
  String get waitingForCustomer => translate('waiting_for_customer');
  String get amount => translate('amount');
  String get askCustomerTap => translate('ask_customer_tap');
  String get cancel => translate('cancel');
  String get paymentReceivedTitle => translate('payment_received_title');
  String get token => translate('token');
  String get done => translate('done');
  
  String get transactionHistory => translate('transaction_history');
  String get thisMonth => translate('this_month');
  String get received => translate('received');
  String get sent => translate('sent');
  String get all => translate('all');
  String get topUp => translate('top_up');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get thisWeek => translate('this_week');
  
  String get language => translate('language');
  String get english => translate('english');
  String get arabic => translate('arabic');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
