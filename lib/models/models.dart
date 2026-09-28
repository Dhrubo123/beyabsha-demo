double _number(dynamic value) => double.tryParse('$value') ?? 0;
int _integer(dynamic value) => int.tryParse('$value') ?? 0;

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.email = '',
    this.businessId,
    this.branchId,
    this.businessName = '',
    this.branchName = '',
  });
  final int id;
  final String name, email, role, businessName, branchName;
  final int? businessId, branchId;
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: _integer(json['id']),
    name: '${json['name'] ?? ''}',
    email: '${json['email'] ?? ''}',
    role: '${json['role'] ?? ''}',
    businessId: json['business_id'] == null
        ? null
        : _integer(json['business_id']),
    branchId: json['branch_id'] == null ? null : _integer(json['branch_id']),
    businessName: '${(json['business'] as Map?)?['name'] ?? ''}',
    branchName: '${(json['branch'] as Map?)?['name'] ?? ''}',
  );
}

class Branch {
  const Branch({required this.id, required this.name, this.location = ''});
  final int id;
  final String name, location;
  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: _integer(json['id']),
    name: '${json['name'] ?? ''}',
    location: '${json['address'] ?? ''}',
  );
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.price,
    required this.stock,
    required this.reorder,
    this.barcode = '',
  });
  final int id;
  final String name, sku, unit, barcode;
  final double price, reorder;
  double stock;
  factory Product.fromStockJson(Map<String, dynamic> json) {
    final product = Map<String, dynamic>.from(
      json['product'] as Map? ?? const {},
    );
    final unit = Map<String, dynamic>.from(product['unit'] as Map? ?? const {});
    return Product(
      id: _integer(product['id'] ?? json['product_id']),
      name: '${product['name'] ?? ''}',
      sku: '${product['sku'] ?? ''}',
      barcode: '${product['barcode'] ?? ''}',
      unit: '${unit['symbol'] ?? unit['name'] ?? ''}',
      price: _number(product['selling_price']),
      stock: _number(json['quantity']),
      reorder: _number(json['reorder_level']),
    );
  }
}

class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.person,
    required this.mobile,
    required this.due,
    required this.limit,
    required this.age,
  });
  final int id;
  final String name, person, mobile, age;
  final double limit;
  double due;
  factory Customer.fromJson(Map<String, dynamic> json) {
    final dueSince = DateTime.tryParse('${json['due_since'] ?? ''}');
    final days = dueSince == null
        ? 0
        : DateTime.now().difference(dueSince).inDays;
    final age = _number(json['current_due']) <= 0
        ? 'পরিশোধিত'
        : days <= 30
        ? '০–৩০ দিন'
        : days <= 60
        ? '৩১–৬০ দিন'
        : days <= 90
        ? '৬১–৯০ দিন'
        : '৯০+ দিন';
    return Customer(
      id: _integer(json['id']),
      name: '${json['name'] ?? ''}',
      person: '${json['contact_person'] ?? ''}',
      mobile: '${json['mobile'] ?? ''}',
      due: _number(json['current_due']),
      limit: _number(json['credit_limit']),
      age: age,
    );
  }
}

class SalesInvoice {
  const SalesInvoice({
    required this.id,
    required this.number,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
    this.salesperson = '',
    this.returnStatus = 'none',
  });
  final int id;
  final String number, customer, status, salesperson, date, returnStatus;
  final double amount;
  factory SalesInvoice.fromJson(Map<String, dynamic> json) => SalesInvoice(
    id: _integer(json['id']),
    number: '${json['invoice_number'] ?? ''}',
    customer: '${(json['customer'] as Map?)?['name'] ?? ''}',
    amount: _number(json['grand_total']),
    status: '${json['payment_status'] ?? ''}',
    salesperson: '${(json['user'] as Map?)?['name'] ?? ''}',
    date: '${json['invoice_date'] ?? ''}',
    returnStatus: '${json['return_status'] ?? 'none'}',
  );
}

class Payment {
  const Payment({
    required this.id,
    required this.customer,
    required this.amount,
    required this.method,
    required this.receipt,
    required this.date,
  });
  final int id;
  final String customer, method, receipt, date;
  final double amount;
  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: _integer(json['id']),
    customer: '${(json['customer'] as Map?)?['name'] ?? ''}',
    amount: _number(json['amount']),
    method: '${json['method'] ?? ''}',
    receipt: '${json['receipt_number'] ?? ''}',
    date: '${json['collection_date'] ?? ''}',
  );
}

class DashboardSummary {
  const DashboardSummary({
    this.sales = 0,
    this.collection = 0,
    this.expenses = 0,
    this.profit = 0,
    this.due = 0,
    this.lowStock = 0,
    this.branches = const [],
  });
  final double sales, collection, expenses, profit, due;
  final int lowStock;
  final List<BranchPerformance> branches;
  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        sales: _number(json['sales']),
        collection: _number(json['net_collections'] ?? json['collections']),
        expenses: _number(json['expenses']),
        profit: _number(json['net_profit']),
        due: _number(json['due']),
        lowStock: _integer(json['low']),
        branches: (json['branches'] as List? ?? const []).map((e) {
          final row = Map<String, dynamic>.from(e as Map);
          return BranchPerformance(
            '${(row['branch'] as Map?)?['name'] ?? 'শাখা'}',
            _number(row['total']),
          );
        }).toList(),
      );
}

class MonthlySale {
  const MonthlySale(this.month, this.sales);
  final String month;
  final double sales;
  factory MonthlySale.fromJson(Map<String, dynamic> json) =>
      MonthlySale('${json['month'] ?? ''}', _number(json['sales']));
}

class SalesRoute {
  const SalesRoute({
    required this.id,
    required this.name,
    required this.date,
    required this.visits,
  });
  final int id;
  final String name, date;
  final List<RouteVisit> visits;
  factory SalesRoute.fromJson(Map<String, dynamic> json) => SalesRoute(
    id: _integer(json['id']),
    name: '${json['name'] ?? 'বিক্রয় রুট'}',
    date: '${json['route_date'] ?? ''}',
    visits: (json['visits'] as List? ?? const [])
        .map((e) => RouteVisit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

class RouteVisit {
  const RouteVisit({
    required this.id,
    required this.name,
    required this.time,
    required this.state,
  });
  final int id;
  final String name, time, state;
  factory RouteVisit.fromJson(Map<String, dynamic> json) => RouteVisit(
    id: _integer(json['id']),
    name: '${(json['customer'] as Map?)?['name'] ?? ''}',
    time: '${json['scheduled_time'] ?? ''}',
    state: '${json['status'] ?? 'pending'}',
  );
}

class TransactionItem {
  const TransactionItem(this.title, this.time, this.amount, this.positive);
  final String title, time;
  final double amount;
  final bool positive;
}

class BranchPerformance {
  const BranchPerformance(this.name, this.sales);
  final String name;
  final double sales;
}
