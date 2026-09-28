import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_client.dart';
import '../../../services/app_store.dart';
import '../../shared/app_ui.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final route = store.routes.isEmpty ? null : store.routes.first;
    return PageWrap(
      title: 'বিক্রয় রুট',
      child: RefreshIndicator(
        onRefresh: store.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (route == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 56,
                      color: AppColors.green,
                    ),
                    SizedBox(height: 12),
                    Text('কোনো রুট নির্ধারণ করা নেই'),
                    Text(
                      'প্রয়োজনে Vue admin panel থেকে রুট তৈরি করুন।',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  route.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(route.date),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F2E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: RoutePainter(),
                    ),
                    ...List.generate(
                      route.visits.length.clamp(0, 5),
                      (i) => Positioned(
                        left: 35.0 + i * 58,
                        top: i.isEven ? 65 : 120,
                        child: CircleAvatar(
                          backgroundColor: route.visits[i].state == 'completed'
                              ? AppColors.green
                              : AppColors.blue,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...route.visits.map(
                (v) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${route.visits.indexOf(v) + 1}'),
                    ),
                    title: Text(v.name),
                    subtitle: Text('${v.time} · ${_state(v.state)}'),
                    trailing: v.state == 'completed'
                        ? const Icon(Icons.check_circle, color: AppColors.green)
                        : FilledButton(
                            onPressed: () => _update(context, v),
                            child: Text(
                              v.state == 'current' ? 'চেক-আউট' : 'চেক-ইন',
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _state(String value) => value == 'completed'
      ? 'সম্পন্ন'
      : value == 'current'
      ? 'চলমান'
      : 'অপেক্ষমাণ';
  Future<void> _update(BuildContext context, RouteVisit visit) async {
    try {
      await context.read<AppStore>().updateVisit(visit);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : '$e')),
        );
      }
    }
  }
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(45, 80)
        ..lineTo(95, 125)
        ..lineTo(150, 70)
        ..lineTo(205, 130)
        ..lineTo(270, 82),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
