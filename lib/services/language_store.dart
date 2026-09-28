import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageStore extends ChangeNotifier {
  static const _storageKey = 'byabsha_language';
  bool _isEnglish = false;

  bool get isEnglish => _isEnglish;
  String get code => _isEnglish ? 'en' : 'bn';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _isEnglish = preferences.getString(_storageKey) == 'en';
    notifyListeners();
  }

  Future<void> setCode(String value) async {
    _isEnglish = value == 'en';
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, code);
  }

  String text(String key) => (_isEnglish ? _english : _bangla)[key] ?? key;

  static const _bangla = <String, String>{
    'language': 'ভাষা', 'bangla': 'বাংলা', 'english': 'English',
    'home': 'হোম', 'sales': 'বিক্রয়', 'customers': 'গ্রাহক', 'myRoutes': 'আমার রুট', 'stock': 'স্টক', 'reports': 'রিপোর্ট',
    'liveBusinessInfo': 'আপনার ব্যবসার লাইভ তথ্য', 'login': 'লগইন করুন', 'emailOrMobile': 'ইমেইল অথবা মোবাইল', 'enterEmailOrMobile': 'ইমেইল অথবা মোবাইল দিন', 'password': 'পাসওয়ার্ড', 'passwordLength': 'কমপক্ষে ৮ অক্ষরের পাসওয়ার্ড দিন', 'registerBusiness': 'নতুন ব্যবসা রেজিস্টার করুন', 'registerHelp': 'নতুন ব্যবসার জন্য কোম্পানি, প্রধান শাখা ও মালিক অ্যাকাউন্ট তৈরি হবে।',
    'logout': 'লগআউট', 'newSale': 'নতুন বিক্রয়', 'collection': 'পেমেন্ট সংগ্রহ', 'branch': 'শাখা', 'todaySales': 'আজকের বিক্রয়', 'todayCollection': 'আজকের সংগ্রহ', 'todayExpenses': 'আজকের খরচ', 'netProfit': 'নিট লাভ', 'lowStock': 'কম স্টক', 'salesTrend': 'বিক্রয় প্রবণতা', 'recentTransactions': 'সাম্প্রতিক লেনদেন', 'noTransactions': 'এখনো কোনো লেনদেন নেই', 'live': 'লাইভ',
    'customerDue': 'গ্রাহকের বাকি', 'searchCustomer': 'গ্রাহক বা মোবাইল খুঁজুন', 'noCustomers': 'কোনো গ্রাহক পাওয়া যায়নি', 'paymentCollection': 'পেমেন্ট সংগ্রহ', 'selectCustomer': 'গ্রাহক নির্বাচন', 'amount': 'সংগ্রহের পরিমাণ', 'savePayment': 'পেমেন্ট সংরক্ষণ করুন', 'newSaleTitle': 'নতুন বিক্রয়', 'searchProduct': 'পণ্য, SKU বা বারকোড খুঁজুন', 'scanBarcode': 'বারকোড স্ক্যান করুন', 'completeSale': 'বিক্রয় সম্পন্ন করুন', 'all': 'সব', 'due': 'বাকি', 'noInvoices': 'কোনো ইনভয়েস পাওয়া যায়নি', 'sharePdf': 'PDF শেয়ার / প্রিন্ট', 'noStock': 'এই শাখায় কোনো স্টক পাওয়া যায়নি', 'welcome': 'স্বাগতম', 'salesExecutiveToday': 'সেলস এক্সিকিউটিভ · আপনার আজকের কাজ', 'assignedRoutes': 'টি নির্ধারিত রুট', 'routeHelp': 'আমার রুট ট্যাব থেকে ভিজিট চেক-ইন ও চেক-আউট করুন।', 'myRecentTransactions': 'আমার সাম্প্রতিক লেনদেন',
  };

  static const _english = <String, String>{
    'language': 'Language', 'bangla': 'বাংলা', 'english': 'English',
    'home': 'Home', 'sales': 'Sales', 'customers': 'Customers', 'myRoutes': 'My Routes', 'stock': 'Stock', 'reports': 'Reports',
    'liveBusinessInfo': 'Live business information', 'login': 'Log in', 'emailOrMobile': 'Email or mobile', 'enterEmailOrMobile': 'Enter your email or mobile', 'password': 'Password', 'passwordLength': 'Enter at least 8 characters', 'registerBusiness': 'Register new business', 'registerHelp': 'A company, head branch, and owner account will be created for your new business.',
    'logout': 'Log out', 'newSale': 'New sale', 'collection': 'Collect payment', 'branch': 'Branch', 'todaySales': "Today's sales", 'todayCollection': "Today's collection", 'todayExpenses': "Today's expenses", 'netProfit': 'Net profit', 'lowStock': 'Low stock', 'salesTrend': 'Sales trend', 'recentTransactions': 'Recent transactions', 'noTransactions': 'No transactions yet', 'live': 'Live',
    'customerDue': 'Customer due', 'searchCustomer': 'Search customer or mobile', 'noCustomers': 'No customers found', 'paymentCollection': 'Payment collection', 'selectCustomer': 'Select customer', 'amount': 'Collection amount', 'savePayment': 'Save payment', 'newSaleTitle': 'New sale', 'searchProduct': 'Search product, SKU, or barcode', 'scanBarcode': 'Scan barcode', 'completeSale': 'Complete sale', 'all': 'All', 'due': 'Due', 'noInvoices': 'No invoices found', 'sharePdf': 'Share / print PDF', 'noStock': 'No stock is available in this branch', 'welcome': 'Welcome', 'salesExecutiveToday': 'Sales executive · your work for today', 'assignedRoutes': 'assigned routes', 'routeHelp': 'Use My Routes to check in and check out customer visits.', 'myRecentTransactions': 'My recent transactions',
  };
}

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.dependOnInheritedWidgetOfExactType<_LanguageScope>();
    return PopupMenuButton<String>(
      tooltip: language?.store.text('language'),
      icon: const Icon(Icons.language),
      onSelected: (value) => language?.store.setCode(value),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'bn', child: Text(language?.store.text('bangla') ?? 'বাংলা')),
        PopupMenuItem(value: 'en', child: Text(language?.store.text('english') ?? 'English')),
      ],
    );
  }
}

class _LanguageScope extends InheritedWidget {
  const _LanguageScope({required this.store, required this.code, required super.child});
  final LanguageStore store;
  final String code;

  @override
  bool updateShouldNotify(_LanguageScope oldWidget) => oldWidget.code != code;
}

class LanguageScope extends StatelessWidget {
  const LanguageScope({super.key, required this.store, required this.code, required this.child});
  final LanguageStore store;
  final String code;
  final Widget child;

  @override
  Widget build(BuildContext context) => _LanguageScope(store: store, code: code, child: child);
}

extension LocalizedBuildContext on BuildContext {
  String tr(String key) {
    final scope = dependOnInheritedWidgetOfExactType<_LanguageScope>();
    return scope?.store.text(key) ?? key;
  }
}

