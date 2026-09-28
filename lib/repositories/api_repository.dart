import '../models/models.dart';
import 'dart:typed_data';
import '../services/api_client.dart';

class ApiRepository {
  ApiRepository(this.client);
  final ApiClient client;
  List<dynamic> _page(dynamic response) {
    final data = response['data'];
    return data is Map
        ? List<dynamic>.from(data['data'] ?? const [])
        : List<dynamic>.from(data ?? const []);
  }

  Future<AppUser> login(String login, String password) async {
    final json = await client.post(
      'auth/login',
      body: {
        'login': login,
        'password': password,
        'device_name': 'Byabsha 360 Flutter',
      },
    );
    await client.setToken('${json['token']}');
    return AppUser.fromJson(Map<String, dynamic>.from(json['user']));
  }

  Future<AppUser> registerBusiness({
    required String businessName,
    required String branchName,
    required String ownerName,
    required String email,
    required String mobile,
    required String address,
    required String password,
  }) async {
    final json = await client.post(
      'auth/register',
      body: {
        'business_name': businessName,
        'branch_name': branchName,
        'name': ownerName,
        'email': email,
        if (mobile.isNotEmpty) 'mobile': mobile,
        if (address.isNotEmpty) 'address': address,
        'password': password,
        'password_confirmation': password,
        'device_name': 'Byabsha 360 Flutter',
      },
    );
    await client.setToken('${json['token']}');
    return AppUser.fromJson(Map<String, dynamic>.from(json['user']));
  }

  Future<AppUser> me() async {
    final json = await client.get('auth/me');
    return AppUser.fromJson(Map<String, dynamic>.from(json['user']));
  }

  Future<void> logout() async {
    try {
      await client.post('auth/logout');
    } finally {
      await client.clearToken();
    }
  }

  Future<List<Branch>> branches(int businessId) async {
    final json = await client.get('businesses/$businessId/branches');
    return (json['data'] as List)
        .map((e) => Branch.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<DashboardSummary> dashboard({int? branchId}) async {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final query = <String, dynamic>{'from': date, 'to': date};
    if (branchId != null) query['branch_id'] = branchId;
    final json = await client.get('reports/dashboard', query: query);
    return DashboardSummary.fromJson(Map<String, dynamic>.from(json['data']));
  }

  Future<DashboardSummary> report({int? branchId}) async {
    final query = <String, dynamic>{};
    if (branchId != null) query['branch_id'] = branchId;
    final json = await client.get('reports/dashboard', query: query);
    return DashboardSummary.fromJson(Map<String, dynamic>.from(json['data']));
  }

  Future<List<MonthlySale>> monthly({int? branchId}) async {
    final query = <String, dynamic>{};
    if (branchId != null) query['branch_id'] = branchId;
    final json = await client.get('reports/monthly', query: query);
    return (json['data'] as List)
        .map((e) => MonthlySale.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Product>> stocks(int branchId) async {
    final json = await client.get(
      'inventory/stocks',
      query: {'branch_id': branchId},
    );
    return (json['data'] as List)
        .map((e) => Product.fromStockJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Customer>> customers(int branchId) async {
    final json = await client.get(
      'customers',
      query: {'per_page': 100, 'branch_id': branchId},
    );
    return _page(
      json,
    ).map((e) => Customer.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<SalesInvoice>> invoices(int branchId) async {
    final json = await client.get(
      'invoices',
      query: {'per_page': 100, 'branch_id': branchId},
    );
    return _page(
      json,
    ).map((e) => SalesInvoice.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Payment>> payments(int branchId) async {
    final json = await client.get(
      'payments',
      query: {'per_page': 20, 'branch_id': branchId},
    );
    return _page(
      json,
    ).map((e) => Payment.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<SalesRoute>> routes() async {
    final json = await client.get('field-sales/routes');
    return (json['data'] as List)
        .map((e) => SalesRoute.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<SalesInvoice> createInvoice({
    required int branchId,
    required Customer customer,
    required Map<Product, int> cart,
    required String method,
    String? transactionId,
  }) async {
    final total = cart.entries.fold<double>(
      0,
      (sum, item) => sum + item.key.price * item.value,
    );
    final paid = method == 'credit' ? 0 : total;
    final json = await client.post(
      'invoices',
      body: {
        'branch_id': branchId,
        'customer_id': customer.id,
        'paid_amount': paid,
        'payment_method': method == 'credit' ? 'cash' : method,
        if (transactionId?.isNotEmpty == true) 'transaction_id': transactionId,
        'items': cart.entries
            .map(
              (e) => {
                'product_id': e.key.id,
                'quantity': e.value,
                'unit_price': e.key.price,
              },
            )
            .toList(),
      },
    );
    final data = Map<String, dynamic>.from(json['data']);
    data['customer'] = {'name': customer.name};
    return SalesInvoice.fromJson(data);
  }

  Future<Payment> collect({
    required int branchId,
    required Customer customer,
    required double amount,
    required String method,
    String? transactionId,
  }) async {
    final json = await client.post(
      'payments',
      body: {
        'branch_id': branchId,
        'customer_id': customer.id,
        'amount': amount,
        'method': method,
        if (transactionId?.isNotEmpty == true) 'transaction_id': transactionId,
      },
    );
    return Payment.fromJson(Map<String, dynamic>.from(json['data']));
  }

  Future<Uint8List> invoicePdf(int invoiceId) =>
      client.getBytes('invoices/$invoiceId/pdf');

  Future<Uint8List> receiptPdf(int paymentId) =>
      client.getBytes('payments/$paymentId/receipt');

  Future<void> adjustStock({
    required int branchId,
    required Product product,
    required double quantity,
    required String reason,
  }) async {
    await client.post(
      'inventory/adjustments',
      body: {
        'branch_id': branchId,
        'product_id': product.id,
        'quantity': quantity,
        'reason': reason,
      },
    );
  }

  Future<void> updateVisit(int visitId, String action) async {
    await client.post('field-sales/visits/$visitId', body: {'action': action});
  }
}
