import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_client.dart';
import '../../../services/app_store.dart';
import '../../../services/language_store.dart';
import '../../shared/app_ui.dart';
import 'barcode_scanner_screen.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});
  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  Customer? customer;
  final Map<Product, int> cart = {};
  final transaction = TextEditingController();
  String method = 'cash';
  bool saving = false;
  String search = '';
  @override
  void dispose() {
    transaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = context.tr;
    final total = cart.entries.fold<double>(
      0,
      (sum, entry) => sum + entry.key.price * entry.value,
    );
    final products = store.products.where(
      (p) =>
          search.isEmpty ||
          p.name.toLowerCase().contains(search.toLowerCase()) ||
          p.sku.toLowerCase().contains(search.toLowerCase()) ||
          p.barcode == search,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l('newSaleTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Customer>(
            initialValue: customer,
            hint: Text(l('selectCustomer')),
            isExpanded: true,
            items: store.customers
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => customer = value),
          ),
          if (customer != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'বর্তমান বাকি: ${money(customer!.due)} · ক্রেডিট সীমা: ${money(customer!.limit)}',
              ),
            ),
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: InputDecoration(
              hintText: l('searchProduct'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: l('scanBarcode'),
                onPressed: _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l('noStock'))),
            ),
          ...products.map(_productRow),
          const Divider(),
          Text(
            'সর্বমোট  ${money(total)}',
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            children: ['cash', 'bank', 'bkash', 'nagad', 'credit']
                .map(
                  (value) => ChoiceChip(
                    label: Text(
                      value == 'credit'
                          ? l('due')
                          : value == 'bkash'
                          ? 'bKash'
                          : value[0].toUpperCase() + value.substring(1),
                    ),
                    selected: method == value,
                    onSelected: (_) => setState(() => method = value),
                  ),
                )
                .toList(),
          ),
          if (!['cash', 'credit'].contains(method))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: transaction,
                decoration: const InputDecoration(labelText: 'Transaction ID'),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed:
                customer == null ||
                    cart.isEmpty ||
                    saving ||
                    (!['cash', 'credit'].contains(method) &&
                        transaction.text.trim().isEmpty)
                ? null
                : () => _complete(total),
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l('completeSale')),
          ),
        ],
      ),
    );
  }

  Widget _productRow(Product product) {
    final quantity = cart[product] ?? 0;
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(
          '${product.unit} · স্টক ${product.stock.toStringAsFixed(product.stock % 1 == 0 ? 0 : 2)} · ${money(product.price)}',
        ),
        trailing: quantity == 0
            ? IconButton(
                onPressed: product.stock <= 0
                    ? null
                    : () => setState(() => cart[product] = 1),
                icon: const Icon(Icons.add_circle, color: AppColors.green),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      if (quantity == 1) {
                        cart.remove(product);
                      } else {
                        cart[product] = quantity - 1;
                      }
                    }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$quantity'),
                  IconButton(
                    onPressed: quantity >= product.stock
                        ? null
                        : () => setState(() => cart[product] = quantity + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || barcode == null || barcode.isEmpty) return;
    final product = context
        .read<AppStore>()
        .products
        .cast<Product?>()
        .firstWhere(
          (item) => item?.barcode.trim() == barcode.trim(),
          orElse: () => null,
        );
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('বারকোড $barcode-এর কোনো পণ্য পাওয়া যায়নি।')),
      );
      return;
    }
    final currentQuantity = cart[product] ?? 0;
    if (product.stock <= currentQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name}-এর পর্যাপ্ত স্টক নেই।')),
      );
      return;
    }
    setState(() {
      search = '';
      cart[product] = currentQuantity + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} কার্টে যোগ করা হয়েছে।')),
    );
  }

  Future<void> _complete(double total) async {
    setState(() => saving = true);
    try {
      final invoice = await context.read<AppStore>().completeSale(
        customer!,
        cart,
        method,
        transactionId: transaction.text.trim(),
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: AppColors.green,
            size: 48,
          ),
          title: const Text('বিক্রয় সফল!'),
          content: Text(
            'ইনভয়েস: ${invoice.number}\nসর্বমোট: ${money(total)}\nস্টক ও গ্রাহকের হিসাব আপডেট হয়েছে।',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ঠিক আছে'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : '$e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}




