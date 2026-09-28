import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/app_store.dart';
import '../../../services/language_store.dart';
import '../../payments/screens/payment_collection_screen.dart';
import '../../sales/screens/new_invoice_screen.dart';
import '../../shared/app_ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final summary = store.today;
    final l = context.tr;
    if (store.isSalesperson) {
      return PageWrap(
        title: store.user?.businessName.isNotEmpty == true
            ? store.user!.businessName
            : 'Byabsha 360',
        action: Row(mainAxisSize: MainAxisSize.min, children: [const LanguageMenu(), _logoutMenu(context)]),
        child: RefreshIndicator(
          onRefresh: store.refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${l('welcome')}, ${store.user?.name ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              Text(l('salesExecutiveToday')),
              const SizedBox(height: 20),
              Card(
                color: AppColors.mint,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.green,
                    child: Icon(Icons.route, color: Colors.white),
                  ),
                  title: Text('${store.routes.length} ${l('assignedRoutes')}'),
                  subtitle: Text(l('routeHelp')),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.add_shopping_cart),
                    label: Text(l('newSale')),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewInvoiceScreen(),
                      ),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.payments),
                    label: Text(l('collection')),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentCollectionScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l('myRecentTransactions'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              if (store.transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text(l('noTransactions'))),
                )
              else
                ...store.transactions.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.title),
                    subtitle: Text(item.time),
                    trailing: Text(
                      money(item.amount),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return PageWrap(
      title: store.user?.businessName.isNotEmpty == true
          ? store.user!.businessName
          : 'Byabsha 360',
      action: Row(mainAxisSize: MainAxisSize.min, children: [const LanguageMenu(), _logoutMenu(context)]),
      child: RefreshIndicator(
        onRefresh: store.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.mint,
                  child: Icon(Icons.person, color: AppColors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l('welcome')}, ${store.user?.name ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(store.user?.role ?? ''),
                    ],
                  ),
                ),
                const Icon(Icons.cloud_done, color: AppColors.green),
                const Text(' লাইভ'),
              ],
            ),
            if (store.branches.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: DropdownButtonFormField<Branch>(
                  initialValue: store.selectedBranch,
                  decoration: const InputDecoration(
                    labelText: 'শাখা',
                    prefixIcon: Icon(Icons.store),
                  ),
                  items: store.branches
                      .map(
                        (b) => DropdownMenuItem(value: b, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: (b) {
                    if (b != null) store.changeBranch(b);
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(store.branchName),
              ),
            if (store.error != null)
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                  ),
                  title: Text(store.error!),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: store.refreshAll,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.darkGreen, AppColors.green],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আজকের বিক্রয়',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    money(summary.sales),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'আপনার ব্যবসার আজকের হিসাব',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.65,
              children: [
                Kpi(
                  l('todayCollection'),
                  money(summary.collection),
                  Icons.payments,
                  AppColors.blue,
                ),
                Kpi(
                  l('todayExpenses'),
                  money(summary.expenses),
                  Icons.receipt,
                  AppColors.amber,
                ),
                Kpi(
                  l('netProfit'),
                  money(summary.profit),
                  Icons.trending_up,
                  AppColors.green,
                ),
                Kpi(
                  l('lowStock'),
                  '${summary.lowStock}',
                  Icons.warning_amber,
                  AppColors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'বিক্রয় প্রবণতা',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 160,
                  child: SalesChart(sales: store.monthlySales),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add_shopping_cart),
                  label: Text(l('newSale')),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewInvoiceScreen()),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.payments),
                  label: Text(l('collection')),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentCollectionScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'সাম্প্রতিক লেনদেন',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            if (store.transactions.isEmpty)
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text(l('noTransactions'))),
                )
            else
              ...store.transactions.map(
                (x) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(x.title),
                  subtitle: Text(x.time),
                  trailing: Text(
                    money(x.amount),
                    style: TextStyle(
                      color: x.positive ? AppColors.green : AppColors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuButton<String> _logoutMenu(BuildContext context) =>
      PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'logout') {
            await context.read<AppStore>().logout();
            if (context.mounted) context.go('/login');
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [Icon(Icons.logout), SizedBox(width: 8), Text(context.tr('logout'))],
            ),
          ),
        ],
      );
}



