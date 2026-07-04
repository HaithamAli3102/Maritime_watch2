import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/notice_banner.dart';
import '../widgets/shared_widgets.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const NoticeBanner(
              kind: NoticeKind.ok,
              icon: '🙏',
              text: "Thank you for helping protect Tanzania's coast. Every report goes "
                  'directly to the Marine Department response team.',
            ),
            const SectionHeader('About'),
            const AppCard(
              child: Text(
                'Maritime Watch is run by the Marine Department of Tanzania. All reports '
                'are reviewed by trained officers. No account is required — reports can '
                'be fully anonymous.',
                style: TextStyle(fontSize: 13, color: AppColors.dim, height: 1.65),
              ),
            ),
            const SizedBox(height: 6),
            const SectionHeader('Contact & Emergency'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ContactTile(
                    icon: Icons.call,
                    title: 'Emergency Maritime Line',
                    subtitle: '+255 800 110 022',
                    subtitleColor: AppColors.wave,
                  ),
                  const Divider(height: 1, color: Color(0x0DFFFFFF)),
                  _ContactTile(
                    icon: Icons.email_outlined,
                    title: 'Marine Department HQ',
                    subtitle: 'info@marine.go.tz',
                    subtitleColor: AppColors.wave,
                  ),
                  const Divider(height: 1, color: Color(0x0DFFFFFF)),
                  _ContactTile(
                    icon: Icons.help_outline,
                    title: 'Frequently Asked Questions',
                    trailing: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Maritime Watch v3.0 · Marine Department of Tanzania\nNo account required · Fully anonymous reporting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.dimmer, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final bool trailing;

  const _ContactTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w700)),
          if (trailing) const Icon(Icons.chevron_right, size: 18, color: AppColors.dimmer),
        ],
      ),
    );
  }
}
