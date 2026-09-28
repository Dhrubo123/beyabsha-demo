import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_client.dart';
import '../../../services/app_store.dart';
import '../../shared/app_ui.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int tab = 0;
  String search = '';
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final items = store.products.where(
      (p) =>
          (search.isEmpty ||
              p.name.toLowerCase().contains(search.toLowerCase()) ||
              p.sku.toLowerCase().contains(search.toLowerCase())) &&
          (tab == 0 ||
              (tab == 1 && p.stock > 0 && p.stock <= p.reorder) ||
              (tab == 2 && p.stock <= 0)),
    );
    return PageWrap(
      title: 'স্টক · ${store.branchName}',
      child: RefreshIndicator(
        onRefresh: store.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(
                hintText: 'পণ্য বা SKU খুঁজুন',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('সব')),
                ButtonSegment(value: 1, label: Text('কম স্টক')),
                ButtonSegment(value: 2, label: Text('স্টক শেষ')),
              ],
              selected: {tab},
              onSelectionChanged: (value) => setState(() => tab = value.first),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('কোনো স্টক পাওয়া যায়নি')),
              ),
            ...items.map(
              (p) => _ProductTile(product: p, onAdjust: () => _adjust(p)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjust(Product product) async {
    final controller = TextEditingController(text: '1');
    bool remove = false;
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: const Text('স্টক সমন্বয়'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${product.name}\nবর্তমান স্টক: ${product.stock}'),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'পরিমাণ'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('স্টক থেকে বাদ দিন'),
                value: remove,
                onChanged: (v) => setDialogState(() => remove = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('বন্ধ করুন'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.pop(dialogContext, remove ? -value : value);
                }
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    try {
      await context.read<AppStore>().adjust(product, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : '$e')),
        );
      }
    }
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onAdjust});
  final Product product;
  final VoidCallback onAdjust;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onAdjust,
      title: Text(product.name),
      subtitle: Text(
        '${product.sku} · ${product.unit} · পুনঃঅর্ডার: ${product.reorder}',
      ),
      leading: const CircleAvatar(
        backgroundColor: AppColors.mint,
        child: Icon(Icons.inventory_2, color: AppColors.green),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${product.stock}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Status(
            product.stock <= 0
                ? 'Out'
                : product.stock <= product.reorder
                ? 'Low'
                : 'OK',
          ),
        ],
      ),
    ),
  );
}
