import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_store.dart';
import '../services/language_store.dart';
import 'customers/screens/customers_screen.dart';
import 'dashboard/screens/dashboard_screen.dart';
import 'field_sales/screens/route_screen.dart';
import 'inventory/screens/inventory_screen.dart';
import 'reports/screens/reports_screen.dart';
import 'sales/screens/sales_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final destinations = <NavigationDestination>[
      NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: context.tr('home')),
      NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: context.tr('sales')),
      NavigationDestination(icon: const Icon(Icons.people_outline), label: context.tr('customers')),
      if (store.isSalesperson) NavigationDestination(icon: const Icon(Icons.route_outlined), label: context.tr('myRoutes')),
      if (store.canManageInventory) NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), label: context.tr('stock')),
      if (store.canViewReports) NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), label: context.tr('reports')),
    ];
    final screens = <Widget>[
      const DashboardScreen(),
      const SalesListScreen(),
      const CustomersScreen(),
      if (store.isSalesperson) const RouteScreen(),
      if (store.canManageInventory) const InventoryScreen(),
      if (store.canViewReports) const ReportsScreen(),
    ];
    if (index >= screens.length) index = 0;

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: screens)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: destinations,
      ),
    );
  }
}
