import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';

String money(num value) {
  final v = value.round().toString();
  return '৳${v.replaceAllMapped(RegExp(r'(?<!^)(?=(\d{3})+(?!\d))'), (_) => ',')}';
}

class PageWrap extends StatelessWidget {
  const PageWrap({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext c) => Column(
    children: [
      AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [?action, const SizedBox(width: 8)],
      ),
      Expanded(child: child),
    ],
  );
}

class Kpi extends StatelessWidget {
  const Kpi(this.label, this.value, this.icon, this.color, {super.key});
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext c) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox(this.hint, {super.key});
  final String hint;
  @override
  Widget build(BuildContext c) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
    ),
  );
}

class Status extends StatelessWidget {
  const Status(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext c) {
    final color = text == 'Due' || text == 'Out'
        ? AppColors.red
        : text == 'Partial' || text == 'Low'
        ? AppColors.amber
        : AppColors.green;
    return Text(
      text,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
    );
  }
}

class SalesChart extends StatelessWidget {
  const SalesChart({super.key, required this.sales});
  final List<MonthlySale> sales;

  @override
  Widget build(BuildContext c) {
    if (sales.isEmpty) {
      return const Center(child: Text('এখনো বিক্রয়ের তথ্য নেই'));
    }
    final spots = List<FlSpot>.generate(
      sales.length,
      (index) => FlSpot(index.toDouble(), sales[index].sales),
    );
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.green,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.mint),
            dotData: const FlDotData(show: true),
            spots: spots,
          ),
        ],
      ),
    );
  }
}
