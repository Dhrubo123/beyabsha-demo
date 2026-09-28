import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_store.dart';
import '../../shared/app_ui.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final report = store.report;
    final months = store.monthlySales;
    return PageWrap(
      title: 'রিপোর্ট',
      child: RefreshIndicator(
        onRefresh: store.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'মাসিক বিক্রয়',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 220,
                  child: months.isEmpty
                      ? const Center(
                          child: Text('রিপোর্টের জন্য বিক্রয় তথ্য নেই'),
                        )
                      : BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            barGroups: months
                                .asMap()
                                .entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.sales,
                                        color: AppColors.green,
                                        width: 18,
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Kpi(
                    'মোট বিক্রয়',
                    money(report.sales),
                    Icons.show_chart,
                    AppColors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Kpi(
                    'নিট লাভ',
                    money(report.profit),
                    Icons.account_balance,
                    AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Kpi(
                    'সংগ্রহ',
                    money(report.collection),
                    Icons.payments,
                    AppColors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Kpi(
                    'খরচ',
                    money(report.expenses),
                    Icons.receipt_long,
                    AppColors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'শাখার কর্মক্ষমতা',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Card(
              child: Column(
                children: report.branches.isEmpty
                    ? [const ListTile(title: Text('কোনো শাখা তথ্য নেই'))]
                    : report.branches
                          .map(
                            (b) => ListTile(
                              title: Text(b.name),
                              trailing: Text(money(b.sales)),
                            ),
                          )
                          .toList(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('মোট গ্রাহক বাকি'),
              trailing: Text(
                money(report.due),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
