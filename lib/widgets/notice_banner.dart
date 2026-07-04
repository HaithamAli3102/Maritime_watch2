import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NoticeKind { info, warn, ok, soft }

class NoticeBanner extends StatelessWidget {
  final NoticeKind kind;
  final String icon;
  final String text;
  final EdgeInsets margin;

  const NoticeBanner({
    super.key,
    required this.kind,
    required this.icon,
    required this.text,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color border;
    switch (kind) {
      case NoticeKind.info:
        bg = AppColors.sky.withOpacity(0.1);
        border = AppColors.sky.withOpacity(0.24);
        break;
      case NoticeKind.warn:
        bg = AppColors.danger.withOpacity(0.1);
        border = AppColors.danger.withOpacity(0.28);
        break;
      case NoticeKind.ok:
        bg = AppColors.ok.withOpacity(0.1);
        border = AppColors.ok.withOpacity(0.28);
        break;
      case NoticeKind.soft:
        bg = Colors.white.withOpacity(0.05);
        border = AppColors.cardBorder;
        break;
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 17)),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.dim, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper for bold spans inside notice text, e.g. NoticeBanner.rich(...)
class BoldSpanText extends StatelessWidget {
  final List<TextSpan> spans;
  const BoldSpanText(this.spans, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: AppColors.dim, height: 1.5),
        children: spans,
      ),
    );
  }
}
