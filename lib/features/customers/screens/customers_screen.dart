import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/app_store.dart';
import '../../../services/language_store.dart';
import '../../payments/screens/payment_collection_screen.dart';
import '../../sales/screens/new_invoice_screen.dart';
import '../../shared/app_ui.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String search = '';
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final customers = store.customers.where(
      (c) =>
          search.isEmpty ||
          c.name.toLowerCase().contains(search.toLowerCase()) ||
          c.mobile.contains(search),
    );
    return PageWrap(
      title: context.tr('customerDue'),
      child: RefreshIndicator(
        onRefresh: store.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: const InputDecoration(
                hintText: 'গ্রাহক বা মোবাইল খুঁজুন',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (customers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('কোনো গ্রাহক পাওয়া যায়নি')),
              ),
            ...customers.map((c) => _CustomerCard(customer: c)),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});
  final Customer customer;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: () => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => CustomerDetails(customer),
      ),
      leading: const CircleAvatar(
        backgroundColor: AppColors.mint,
        child: Icon(Icons.store, color: AppColors.green),
      ),
      title: Text(customer.name),
      subtitle: Text(
        '${customer.person}${customer.mobile.isEmpty ? '' : ' · ${customer.mobile}'}\n${customer.age}',
      ),
      isThreeLine: true,
      trailing: Text(
        money(customer.due),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: customer.due > 0 ? AppColors.red : AppColors.green,
        ),
      ),
    ),
  );
}

class CustomerDetails extends StatelessWidget {
  const CustomerDetails(this.customer, {super.key});
  final Customer customer;
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(customer.name, style: Theme.of(context).textTheme.titleLarge),
            Text(
              'বকেয়া: ${money(customer.due)} / সীমা: ${money(customer.limit)}',
            ),
            const SizedBox(height: 12),
            if (store.canCreateSale)
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewInvoiceScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text(context.tr('newSale')),
              ),
            if (store.canCollectPayment)
              FilledButton.icon(
                onPressed: customer.due <= 0
                    ? null
                    : () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentCollectionScreen(
                              initialCustomer: customer,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.payments),
                label: Text(context.tr('collection')),
              ),
          ],
        ),
      ),
    );
  }
}

