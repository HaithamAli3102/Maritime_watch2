import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/zones_data.dart';
import '../widgets/notice_banner.dart';
import 'root_shell.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noEntry = tanzaniaZones.where((z) => z.level == ZoneLevel.noEntry).toList();
    final restricted = tanzaniaZones.where((z) => z.level == ZoneLevel.restricted).toList();
    final monitored = tanzaniaZones.where((z) => z.level == ZoneLevel.monitored).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Restricted Zones')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const NoticeBanner(
              kind: NoticeKind.info,
              icon: 'ℹ️',
              text:
                  "These are Tanzania's officially protected maritime zones. If you "
                  'see a boat inside any of them, please report it immediately.',
            ),
            const _GroupHeader('⛔ No Entry — Fully Protected'),
            ...noEntry.map((z) => _ZoneCard(zone: z)),
            const SizedBox(height: 4),
            const _GroupHeader('⚠️ Restricted — Permit Required'),
            ...restricted.map((z) => _ZoneCard(zone: z)),
            const SizedBox(height: 4),
            const _GroupHeader('🌿 Monitored — Conservation Areas'),
            ...monitored.map((z) => _ZoneCard(zone: z)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.campaign, size: 18),
                label: const Text("Report a Boat You've Seen"),
                onPressed: () {
                  context.findAncestorStateOfType<RootShellState>()?.goTo(2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String text;
  const _GroupHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.wave,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final MaritimeZone zone;
  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color border;
    late Color pillBg;
    late Color pillText;
    late String icon;

    switch (zone.level) {
      case ZoneLevel.noEntry:
        bg = AppColors.danger.withOpacity(0.11);
        border = AppColors.danger.withOpacity(0.28);
        pillBg = AppColors.danger.withOpacity(0.24);
        pillText = const Color(0xFFEF9A9A);
        icon = '⛔';
        break;
      case ZoneLevel.restricted:
        bg = AppColors.warn.withOpacity(0.09);
        border = AppColors.warn.withOpacity(0.26);
        pillBg = AppColors.warn.withOpacity(0.22);
        pillText = const Color(0xFFFFCC80);
        icon = '⚠️';
        break;
      case ZoneLevel.monitored:
        bg = AppColors.sky.withOpacity(0.08);
        border = AppColors.sky.withOpacity(0.22);
        pillBg = AppColors.sky.withOpacity(0.2);
        pillText = AppColors.wave;
        icon = '🌿';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 2),
                Text(zone.coordRange,
                    style: TextStyle(fontSize: 10, color: AppColors.dimmer, fontFamily: 'monospace')),
                const SizedBox(height: 3),
                Text(zone.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.dim, height: 1.45)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    zone.levelLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pillText, letterSpacing: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
