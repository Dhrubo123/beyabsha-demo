import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_client.dart';
import '../../../services/app_store.dart';
import '../../../services/pdf_share_service.dart';
import '../../shared/app_ui.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({super.key, this.initialCustomer});
  final Customer? initialCustomer;
  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  Customer? customer;
  final amount = TextEditingController();
  final transaction = TextEditingController();
  String method = 'cash';
  bool saving = false;
  @override
  void initState() {
    super.initState();
    customer = widget.initialCustomer;
  }

  @override
  void dispose() {
    amount.dispose();
    transaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final entered = double.tryParse(amount.text);
    return Scaffold(
      appBar: AppBar(title: const Text('পেমেন্ট সংগ্রহ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Customer>(
            initialValue: customer,
            hint: const Text('গ্রাহক নির্বাচন'),
            isExpanded: true,
            items: store.customers
                .where((c) => c.due > 0)
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
              child: Text('বকেয়া: ${money(customer!.due)}'),
            ),
          TextField(
            controller: amount,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'সংগ্রহের পরিমাণ',
              prefixText: '৳ ',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['cash', 'bank', 'bkash', 'nagad']
                .map(
                  (value) => ChoiceChip(
                    label: Text(
                      value == 'bkash'
                          ? 'bKash'
                          : value[0].toUpperCase() + value.substring(1),
                    ),
                    selected: method == value,
                    onSelected: (_) => setState(() => method = value),
                  ),
                )
                .toList(),
          ),
          if (method != 'cash')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: transaction,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Transaction ID'),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                customer == null ||
                    entered == null ||
                    entered <= 0 ||
                    entered > customer!.due ||
                    saving ||
                    (method != 'cash' && transaction.text.trim().isEmpty)
                ? null
                : _save,
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('পেমেন্ট সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => saving = true);
    final value = double.parse(amount.text);
    try {
      final payment = await context.read<AppStore>().collect(
        customer!,
        value,
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
          title: const Text('পেমেন্ট সফল!'),
          content: Text(
            'রসিদ: ${payment.receipt}\n${payment.customer} থেকে ${money(value)} গ্রহণ করা হয়েছে।',
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () => _shareReceipt(payment),
              icon: const Icon(Icons.share_outlined),
              label: const Text('PDF রসিদ'),
            ),
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

  Future<void> _shareReceipt(Payment payment) async {
    try {
      final bytes = await context.read<AppStore>().receiptPdf(payment);
      await PdfShareService.share(
        bytes: bytes,
        filename: '${payment.receipt}.pdf',
        title: 'Receipt ${payment.receipt}',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF রসিদ শেয়ার করা যায়নি: $error')),
        );
      }
    }
  }
}
