import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/api_repository.dart';
import 'api_client.dart';

class AppStore extends ChangeNotifier {
  AppStore(this.repo);
  final ApiRepository repo;

  bool loading = false;
  bool bangla = true;
  String? error;
  AppUser? user;
  List<Branch> branches = [];
  Branch? selectedBranch;
  List<Product> products = [];
  List<Customer> customers = [];
  List<SalesInvoice> invoices = [];
  List<Payment> payments = [];
  List<MonthlySale> monthlySales = [];
  List<SalesRoute> routes = [];
  DashboardSummary today = const DashboardSummary();
  DashboardSummary report = const DashboardSummary();

  bool get isLoggedIn => user != null;
  bool get isSalesperson => user?.role == 'salesperson';
  bool get canViewReports => const {
    'owner',
    'manager',
    'accountant',
    'super_admin',
  }.contains(user?.role);
  bool get canManageInventory =>
      const {'owner', 'manager', 'super_admin'}.contains(user?.role);
  bool get canCreateSale => const {
    'owner',
    'manager',
    'salesperson',
    'super_admin',
  }.contains(user?.role);
  bool get canCollectPayment => const {
    'owner',
    'manager',
    'accountant',
    'salesperson',
    'super_admin',
  }.contains(user?.role);
  int? get branchId => selectedBranch?.id ?? user?.branchId;
  String get branchName =>
      selectedBranch?.name ?? user?.branchName ?? 'শাখা নির্বাচন করুন';
  List<TransactionItem> get transactions {
    final rows = <TransactionItem>[
      ...payments
          .take(5)
          .map(
            (p) => TransactionItem(
              '${p.customer} থেকে পেমেন্ট',
              p.date,
              p.amount,
              true,
            ),
          ),
      ...invoices
          .take(5)
          .map(
            (i) => TransactionItem(
              'বিক্রয় · ${i.customer}',
              i.date,
              i.amount,
              true,
            ),
          ),
    ];
    return rows.take(6).toList();
  }

  Future<bool> restoreSession() async {
    if (!await repo.client.hasToken()) return false;
    try {
      user = await repo.me();
      await _loadBusinessData();
      return true;
    } catch (_) {
      await repo.client.clearToken();
      user = null;
      return false;
    }
  }

  Future<void> login(String login, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await repo.login(login, password);
      await _loadBusinessData();
    } catch (e) {
      error = e is ApiException ? e.message : '$e';
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> registerBusiness({
    required String businessName,
    required String branchName,
    required String ownerName,
    required String email,
    required String mobile,
    required String address,
    required String password,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await repo.registerBusiness(
        businessName: businessName,
        branchName: branchName,
        ownerName: ownerName,
        email: email,
        mobile: mobile,
        address: address,
        password: password,
      );
      await _loadBusinessData();
    } catch (e) {
      error = e is ApiException ? e.message : '$e';
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBusinessData() async {
    if (user?.businessId == null) {
      throw const ApiException('এই ব্যবহারকারীর সাথে কোনো ব্যবসা যুক্ত নেই।');
    }
    branches = await repo.branches(user!.businessId!);
    selectedBranch =
        branches.where((b) => b.id == user!.branchId).firstOrNull ??
        (branches.isNotEmpty ? branches.first : null);
    if (selectedBranch == null) {
      throw const ApiException('কোনো সক্রিয় শাখা পাওয়া যায়নি।');
    }
    await refreshAll(showLoader: false);
  }

  Future<void> refreshAll({bool showLoader = true}) async {
    if (branchId == null) return;
    if (showLoader) {
      loading = true;
      notifyListeners();
    }
    error = null;
    try {
      if (canManageInventory || canCreateSale) {
        products = await repo.stocks(branchId!);
      } else {
        products = [];
      }
      customers = await repo.customers(branchId!);
      invoices = await repo.invoices(branchId!);
      payments = await repo.payments(branchId!);
      if (canViewReports) {
        today = await repo.dashboard(branchId: branchId);
        report = await repo.report(branchId: branchId);
        monthlySales = await repo.monthly(branchId: branchId);
      } else {
        today = const DashboardSummary();
        report = const DashboardSummary();
        monthlySales = [];
      }
      try {
        routes = isSalesperson ? await repo.routes() : [];
      } catch (_) {
        routes = [];
      }
    } catch (e) {
      error = e is ApiException ? e.message : '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> changeBranch(Branch branch) async {
    selectedBranch = branch;
    notifyListeners();
    await refreshAll();
  }

  void toggleLanguage() {
    bangla = !bangla;
    notifyListeners();
  }

  Future<SalesInvoice> completeSale(
    Customer customer,
    Map<Product, int> cart,
    String method, {
    String? transactionId,
  }) async {
    if (!canCreateSale) {
      throw const ApiException('এই ব্যবহারকারীর বিক্রয় তৈরির অনুমতি নেই।');
    }
    final invoice = await repo.createInvoice(
      branchId: branchId!,
      customer: customer,
      cart: cart,
      method: method.toLowerCase(),
      transactionId: transactionId,
    );
    await refreshAll(showLoader: false);
    return invoice;
  }

  Future<Payment> collect(
    Customer customer,
    double amount,
    String method, {
    String? transactionId,
  }) async {
    if (!canCollectPayment) {
      throw const ApiException('এই ব্যবহারকারীর পেমেন্ট সংগ্রহের অনুমতি নেই।');
    }
    final payment = await repo.collect(
      branchId: branchId!,
      customer: customer,
      amount: amount,
      method: method.toLowerCase(),
      transactionId: transactionId,
    );
    await refreshAll(showLoader: false);
    return payment;
  }

  Future<Uint8List> invoicePdf(SalesInvoice invoice) => repo.invoicePdf(invoice.id);

  Future<Uint8List> receiptPdf(Payment payment) => repo.receiptPdf(payment.id);

  Future<void> adjust(Product product, double delta) async {
    if (!canManageInventory) {
      throw const ApiException('এই ব্যবহারকারীর স্টক পরিবর্তনের অনুমতি নেই।');
    }
    await repo.adjustStock(
      branchId: branchId!,
      product: product,
      quantity: delta,
      reason: 'Mobile app adjustment',
    );
    await refreshAll(showLoader: false);
  }

  Future<void> updateVisit(RouteVisit visit) async {
    await repo.updateVisit(
      visit.id,
      visit.state == 'current' ? 'check_out' : 'check_in',
    );
    await refreshAll(showLoader: false);
  }

  Future<void> logout() async {
    await repo.logout();
    user = null;
    products = [];
    customers = [];
    invoices = [];
    notifyListeners();
  }
}
