import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/notice_banner.dart';
import '../widgets/shared_widgets.dart';
import 'root_shell.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  void initState() {
    super.initState();
    // Fires once, automatically — no permission dialog, no user action needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.location == null) state.detectLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Location'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: state.locating
                  ? AppColors.sky.withOpacity(0.18)
                  : AppColors.ok.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.locating
                    ? AppColors.sky.withOpacity(0.3)
                    : AppColors.ok.withOpacity(0.3),
              ),
            ),
            child: Text(
              state.locating ? 'DETECTING…' : 'LOCATED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: state.locating ? AppColors.wave : const Color(0xFF81C784),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _LocationCard(state: state),
            const SizedBox(height: 14),
            const _SchematicMap(),
            const SizedBox(height: 18),
            if (!state.locating)
              const NoticeBanner(
                kind: NoticeKind.warn,
                icon: '⚠️',
                text:
                    'Vessel spotted in restricted area. A boat has been flagged inside '
                    'North Reef. Tap below if you can see it.',
              ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                 //  final shell = context.findAncestorStateOfType<RootShellState>();
                 // shell?.goTo(2);
                  Get.back();
                },
                child: const Text('Back →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final AppState state;
  const _LocationCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.sky.withOpacity(0.08),
        border: Border.all(color: AppColors.sky.withOpacity(0.22)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: state.locating
          ? Row(
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.wave),
                ),
                SizedBox(width: 10),
                Text('Detecting your location…',
                    style: TextStyle(fontSize: 13, color: AppColors.wave)),
              ],
            )
          : Column(
              children: [
                KeyValueRow(label: 'Area', value: state.location?.area ?? '—'),
                KeyValueRow(label: 'Region', value: state.location?.region ?? '—'),
                KeyValueRow(label: 'Country', value: state.location?.country ?? '—'),
                KeyValueRow(
                  label: 'Approx. coordinates',
                  value: state.location?.coords ?? '—',
                ),
                KeyValueRow(
                  label: 'Nearest restricted zone',
                  value: state.location?.nearestZoneHint ?? '—',
                  valueColor: const Color(0xFFFFCC80),
                ),
              ],
            ),
    );
  }
}

class _SchematicMap extends StatelessWidget {
  const _SchematicMap();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.cardBorder)),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 346 / 180,
              child: CustomPaint(painter: _TanzaniaMapPainter(), child: Container()),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Schematic — Tanzania Coast',
                  style: TextStyle(fontSize: 10, color: AppColors.dim),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simplified, illustrative rendering of the Tanzanian coastline with
/// approximate zone markers — not for navigational use.
class _TanzaniaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ocean background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0A1E35));

    // Grid
    final gridPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.35)
      ..strokeWidth = 0.5;
    for (var i = 1; i <= 3; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }
    for (var i = 1; i <= 4; i++) {
      final x = w * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Coastline (schematic landmass on the left)
    final land = Path()
      ..moveTo(w * 0.17, h * 0.06)
      ..quadraticBezierTo(w * 0.20, h * 0.11, w * 0.19, h * 0.22)
      ..quadraticBezierTo(w * 0.17, h * 0.33, w * 0.20, h * 0.44)
      ..quadraticBezierTo(w * 0.23, h * 0.55, w * 0.22, h * 0.67)
      ..quadraticBezierTo(w * 0.20, h * 0.78, w * 0.23, h * 0.92)
      ..lineTo(w * 0.26, h)
      ..lineTo(w * 0.52, h)
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..lineTo(w * 0.17, h * 0.06)
      ..close();
    canvas.drawPath(land, Paint()..color = const Color(0xFF1A3A5C).withOpacity(0.65));

    _label(canvas, 'TANZANIA', Offset(w * 0.30, h * 0.55), 9, Colors.white.withOpacity(0.22), bold: true);
    _label(canvas, 'INDIAN OCEAN', Offset(w * 0.66, h * 0.5), 8, Colors.white.withOpacity(0.18));

    // Zone: Zanzibar Channel (red, no entry)
    _zone(canvas, Offset(w * 0.448, h * 0.378), w * 0.081, h * 0.10, const Color(0xFFE53935));
    _label(canvas, 'ZNZ CHANNEL', Offset(w * 0.448, h * 0.40), 7, const Color(0xFFEF9A9A));

    // Zone: Pemba (red)
    _zone(canvas, Offset(w * 0.636, h * 0.194), w * 0.052, h * 0.10, const Color(0xFFE53935));
    _label(canvas, 'PEMBA', Offset(w * 0.636, h * 0.21), 6, const Color(0xFFEF9A9A));

    // Zone: Rufiji Delta (orange, restricted)
    _zone(canvas, Offset(w * 0.376, h * 0.711), w * 0.064, h * 0.078, const Color(0xFFF57C00));
    _label(canvas, 'RUFIJI DELTA', Offset(w * 0.376, h * 0.73), 6, const Color(0xFFFFCC80));

    // Zone: Mnazi Bay (monitored, ok green)
    _zone(canvas, Offset(w * 0.312, h * 0.878), w * 0.04, h * 0.078, const Color(0xFF43A047));
    _label(canvas, 'MNAZI BAY', Offset(w * 0.312, h * 0.90), 6, const Color(0xFFA5D6A7));

    // Zone: Mafia Island (orange)
    _zone(canvas, Offset(w * 0.506, h * 0.639), w * 0.043, h * 0.083, const Color(0xFFF57C00));
    _label(canvas, 'MAFIA IS.', Offset(w * 0.506, h * 0.66), 6, const Color(0xFFFFCC80));

    // User location dot (Dar es Salaam area)
    final userPos = Offset(w * 0.289, h * 0.489);
    canvas.drawCircle(userPos, w * 0.052, Paint()..color = AppColors.sky.withOpacity(0.07));
    canvas.drawCircle(userPos, w * 0.032, Paint()..color = AppColors.sky.withOpacity(0.18));
    canvas.drawCircle(userPos, w * 0.014, Paint()..color = AppColors.sky);
    _label(canvas, 'YOU', userPos + Offset(0, h * 0.105), 7, AppColors.wave, bold: true);
    _label(canvas, 'Dar es Salaam', userPos + Offset(-w * 0.01, -h * 0.028), 7, Colors.white.withOpacity(0.5));

    // Scale bar
    final scaleY = h * 0.933;
    canvas.drawLine(Offset(w * 0.035, scaleY), Offset(w * 0.145, scaleY), Paint()..color = AppColors.wave..strokeWidth = 1);
    _label(canvas, '50 km', Offset(w * 0.09, scaleY + h * 0.045), 7, AppColors.wave);
  }

  void _zone(Canvas canvas, Offset center, double rx, double ry, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.13)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    canvas.drawOval(rect, paint);
    _dashedOval(canvas, rect, strokePaint);
  }

  void _dashedOval(Canvas canvas, Rect rect, Paint paint) {
    const dashCount = 28;
    final path = Path()..addOval(rect);
    final metrics = path.computeMetrics().first;
    final length = metrics.length;
    final dashLen = length / dashCount;
    for (var i = 0; i < dashCount; i += 2) {
      final start = i * dashLen;
      final end = (i + 1) * dashLen;
      final extract = metrics.extractPath(start, end);
      canvas.drawPath(extract, paint);
    }
  }

  void _label(Canvas canvas, String text, Offset center, double fontSize, Color color, {bool bold = false}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontFamily: 'monospace',
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
