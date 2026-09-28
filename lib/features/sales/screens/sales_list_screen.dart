import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/app_store.dart';
import '../../../services/language_store.dart';
import '../../../services/pdf_share_service.dart';
import '../../shared/app_ui.dart';
import 'new_invoice_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});
  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final invoices = store.invoices.where(
      (i) => filter == 'all' || i.status == filter,
    );
    return PageWrap(
      title: context.tr('sales'),
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: store.refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  children: ['all', 'paid', 'partial', 'due']
                      .map(
                        (value) => FilterChip(
                          label: Text(
                            value == 'all' ? context.tr('all') : value.toUpperCase(),
                          ),
                          selected: filter == value,
                          onSelected: (_) => setState(() => filter = value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                if (invoices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('কোনো ইনভয়েস পাওয়া যায়নি')),
                  ),
                ...invoices.map(
                  (x) => Card(
                    child: ListTile(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(x.number),
                          content: Text(
                            'গ্রাহক: ${x.customer}\nতারিখ: ${x.date}\nমোট: ${money(x.amount)}\nপেমেন্ট: ${x.status}',
                          ),
                          actions: [
                            OutlinedButton.icon(
                              onPressed: () => _shareInvoice(context, x),
                              icon: const Icon(Icons.share_outlined),
                              label: Text(context.tr('sharePdf')),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('বন্ধ করুন'),
                            ),
                          ],
                        ),
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.mint,
                        child: Icon(Icons.receipt_long, color: AppColors.green),
                      ),
                      title: Text(x.customer),
                      subtitle: Text('${x.number} · ${x.date}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            money(x.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Status(_label(x.status)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (store.canCreateSale)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewInvoiceScreen()),
                ),
                icon: const Icon(Icons.add),
                label: Text(context.tr('newSale')),
              ),
            ),
        ],
      ),
    );
  }

  String _label(String value) => value == 'paid'
      ? 'Paid'
      : value == 'partial'
      ? 'Partial'
      : value == 'due'
      ? 'Due'
      : value;

  Future<void> _shareInvoice(BuildContext context, SalesInvoice invoice) async {
    try {
      final bytes = await context.read<AppStore>().invoicePdf(invoice);
      await PdfShareService.share(
        bytes: bytes,
        filename: '${invoice.number}.pdf',
        title: 'Invoice ${invoice.number}',
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF শেয়ার করা যায়নি: $error')),
        );
      }
    }
  }
}

