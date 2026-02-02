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
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'push_notifications': 'Push Notifications',
      'email_notifications': 'Email Notifications',
      'transaction_alerts': 'Transaction Alerts',
      'security': 'Security',
      'change_pin': 'Change PIN',
      'biometric_auth': 'Biometric Authentication',
      'two_factor_auth': 'Two-Factor Authentication',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'app_version': 'App Version',
      'help_support': 'Help & Support',
      'contact_us': 'Contact Us',
      'faq': 'FAQ',
      'rate_app': 'Rate App',
      
      // Profile
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'personal_info': 'Personal Information',
      'phone': 'Phone',
      'phone_number': 'Phone Number',
      'member_since': 'Member Since',
      'account_status': 'Account Status',
      'verified': 'Verified',
      'unverified': 'Unverified',
      'save_changes': 'Save Changes',
      'change_photo': 'Change Photo',
      'delete_account': 'Delete Account',
      'delete_account_warning': 'This action cannot be undone. All your data will be permanently deleted.',
      
      // NFC Payment Screen
      'pay': 'Pay',
      'receive': 'Receive',
      'enter_payment_amount': 'Enter Payment Amount',
      'enter_receive_amount': 'Enter Amount to Receive',
      'enter_valid_amount': 'Please enter a valid amount',
      'insufficient_balance': 'Insufficient balance',
      'continue_to_pay': 'Continue to Pay',
      'preparing_transaction': 'Preparing transaction...',
      'paying': 'Paying',
      'receiving': 'Receiving',
      'tap_to_pay': 'Tap to Pay',
      'waiting_for_payment': 'Waiting for Payment',
      'hold_near_receiver': 'Hold your phone near the receiver device',
      'confirm_payment_sent': 'Confirm Payment Sent',
      'processing_payment': 'Processing Payment',
      'please_wait': 'Please wait...',
      'payment_successful': 'Payment Successful!',
      'amount_deducted_successfully': 'Amount deducted from your wallet',
      'payment_received_successfully': 'Payment credited to your wallet',
      'payment_failed': 'Payment Failed',
      'unknown_error': 'An unknown error occurred',
      'try_again': 'Try Again',
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
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'appearance': 'المظهر',
      'dark_mode': 'الوضع الداكن',
      'notifications': 'الإشعارات',
      'push_notifications': 'إشعارات الدفع',
      'email_notifications': 'إشعارات البريد الإلكتروني',
      'transaction_alerts': 'تنبيهات المعاملات',
      'security': 'الأمان',
      'change_pin': 'تغيير الرمز السري',
      'biometric_auth': 'المصادقة البيومترية',
      'two_factor_auth': 'المصادقة الثنائية',
      'about': 'حول',
      'privacy_policy': 'سياسة الخصوصية',
      'terms_of_service': 'شروط الخدمة',
      'app_version': 'إصدار التطبيق',
      'help_support': 'المساعدة والدعم',
      'contact_us': 'اتصل بنا',
      'faq': 'الأسئلة الشائعة',
      'rate_app': 'قيّم التطبيق',
      
      // Profile
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف الشخصي',
      'personal_info': 'المعلومات الشخصية',
      'phone': 'الهاتف',
      'phone_number': 'رقم الهاتف',
      'member_since': 'عضو منذ',
      'account_status': 'حالة الحساب',
      'verified': 'موثق',
      'unverified': 'غير موثق',
      'save_changes': 'حفظ التغييرات',
      'change_photo': 'تغيير الصورة',
      'delete_account': 'حذف الحساب',
      'delete_account_warning': 'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك نهائياً.',
      
      // NFC Payment Screen
      'pay': 'دفع',
      'receive': 'استلام',
      'enter_payment_amount': 'أدخل مبلغ الدفع',
      'enter_receive_amount': 'أدخل المبلغ المراد استلامه',
      'enter_valid_amount': 'يرجى إدخال مبلغ صحيح',
      'insufficient_balance': 'رصيد غير كافٍ',
      'continue_to_pay': 'متابعة الدفع',
      'preparing_transaction': 'جاري تحضير المعاملة...',
      'paying': 'جاري الدفع',
      'receiving': 'جاري الاستلام',
      'tap_to_pay': 'انقر للدفع',
      'waiting_for_payment': 'في انتظار الدفع',
      'hold_near_receiver': 'قرب هاتفك من جهاز المستلم',
      'confirm_payment_sent': 'تأكيد إرسال الدفع',
      'processing_payment': 'جاري معالجة الدفع',
      'please_wait': 'يرجى الانتظار...',
      'payment_successful': 'تم الدفع بنجاح!',
      'amount_deducted_successfully': 'تم خصم المبلغ من محفظتك',
      'payment_received_successfully': 'تم إضافة المبلغ إلى محفظتك',
      'payment_failed': 'فشل الدفع',
      'unknown_error': 'حدث خطأ غير معروف',
      'try_again': 'حاول مرة أخرى',
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
  
  String get settings => translate('settings');
  String get language => translate('language');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get notifications => translate('notifications');
  String get pushNotifications => translate('push_notifications');
  String get emailNotifications => translate('email_notifications');
  String get transactionAlerts => translate('transaction_alerts');
  String get security => translate('security');
  String get changePin => translate('change_pin');
  String get biometricAuth => translate('biometric_auth');
  String get twoFactorAuth => translate('two_factor_auth');
  String get about => translate('about');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get appVersion => translate('app_version');
  String get helpSupport => translate('help_support');
  String get contactUs => translate('contact_us');
  String get faq => translate('faq');
  String get rateApp => translate('rate_app');
  
  // Profile
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get personalInfo => translate('personal_info');
  String get phone => translate('phone');
  String get phoneNumber => translate('phone_number');
  String get memberSince => translate('member_since');
  String get accountStatus => translate('account_status');
  String get verified => translate('verified');
  String get unverified => translate('unverified');
  String get saveChanges => translate('save_changes');
  String get changePhoto => translate('change_photo');
  String get deleteAccount => translate('delete_account');
  String get deleteAccountWarning => translate('delete_account_warning');
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
