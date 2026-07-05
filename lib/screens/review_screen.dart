import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:maritime_watch/screens/report_screen.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/boat_report.dart';
import '../services/app_state.dart';
import '../widgets/notice_banner.dart';
import '../widgets/shared_widgets.dart';
import 'root_shell.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final d = state.draft;

    final zoneName = (d.zoneValue ?? 'Not selected').split(' (').first;
    final timeLabel =
        '${d.sightedAt.day.toString().padLeft(2, '0')}/${d.sightedAt.month.toString().padLeft(2, '0')}/${d.sightedAt.year}  '
        '${d.sightedAt.hour.toString().padLeft(2, '0')}:${d.sightedAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Review Before Sending')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const NoticeBanner(
              kind: NoticeKind.ok,
              icon: '✅',
              text: 'Check the details below. Once sent, the Marine Department will be '
                  'notified. Anonymous reports are equally valid.',
            ),

            _ReviewBlock(
              title: '📍 Location & Zone',
              rows: [
                KeyValueRow(label: 'Spotted at', value: timeLabel),
                KeyValueRow(label: 'Restricted zone', value: zoneName, valueColor: const Color(0xFFEF9A9A)),
                KeyValueRow(
                  label: 'Your detected location',
                  value: '${d.detectedArea}, ${d.detectedRegion}',
                ),
              ],
            ),

            _ReviewBlock(
              title: '🛥️ Boat Details',
              rows: [
                KeyValueRow(label: 'Type', value: d.boatType ?? 'Not specified'),
                KeyValueRow(label: 'Colour', value: d.boatColor.isEmpty ? 'Not specified' : d.boatColor),
                KeyValueRow(label: 'People onboard', value: d.peopleOnboard),
              ],
            ),

            _ReviewBlock(
              title: '📝 Your Description',
              rows: [],
              freeText: d.notes.isEmpty ? 'No description provided.' : d.notes,
            ),

            _ReviewBlock(
              title: '📊 Other',
              rows: [
                KeyValueRow(label: 'Urgency', value: d.urgency.label, valueColor: const Color(0xFFFFCC80)),
                KeyValueRow(
                  label: 'Photos',
                  value: d.photos.isEmpty ? 'No photos' : '${d.photos.length} attached',
                  valueColor: const Color(0xFF81C784),
                ),
              ],
            ),

            _ReviewBlock(
              title: '🙋 Contact Details',
              rows: [
                KeyValueRow(label: 'Name', value: d.contactName.isEmpty ? 'Not provided' : d.contactName),
                KeyValueRow(label: 'Phone', value: d.contactPhone.isEmpty ? 'Not provided' : d.contactPhone),
                KeyValueRow(label: 'Address', value: d.contactAddress.isEmpty ? 'Not provided' : d.contactAddress),
              ],
              footer: '🔒 Confidential — investigators only.',
            ),

            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.wave,
                      side: BorderSide(color: AppColors.wave.withOpacity(0.3), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: (){
                      Get.to(()=>ReportScreen());
                    },
                    // onPressed: () => context.findAncestorStateOfType<RootShellState>()?.goTo(2),
                    child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _submit(context),
                    child: const Text('Send Report 📢'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Your report goes directly to the Marine Department.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.dimmer),
            ),

            const SizedBox(height: 22),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 16),
            const SectionHeader('Your previous reports'),
            ...state.pastReports.map((r) => _PastReportCard(report: r)),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final state = context.read<AppState>();
    final ref = state.submitAndGetReference();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(ref: ref),
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  final String? freeText;
  final String? footer;
  const _ReviewBlock({required this.title, required this.rows, this.freeText, this.footer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.sky.withOpacity(0.08),
              border: const Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.wave, letterSpacing: 1),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: freeText != null ? 12 : 4),
            child: freeText != null
                ? Text(freeText!, style: const TextStyle(fontSize: 13, color: AppColors.dim, height: 1.6))
                : Column(children: rows),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(footer!, style: const TextStyle(fontSize: 11, color: AppColors.dimmer, height: 1.4)),
            ),
        ],
      ),
    );
  }
}

class _PastReportCard extends StatelessWidget {
  final PastReport report;
  const _PastReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (report.status) {
      case 'Reviewed':
        statusColor = const Color(0xFF81C784);
        break;
      case 'Submitted':
        statusColor = AppColors.wave;
        break;
      default:
        statusColor = AppColors.wave;
    }

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 3),
                Text(report.date, style: const TextStyle(fontSize: 11, color: AppColors.dim)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
            child: Text(report.status,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String ref;
  const _SuccessDialog({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.deep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.sky.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📡', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            const Text('Report Sent!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.white)),
            const SizedBox(height: 8),
            const Text(
              'Your report has been received by the Marine Department and is being reviewed by an officer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.dim, height: 1.6),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.sky.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('REF #$ref',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.wave, letterSpacing: 1)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Save this reference number. If you provided contact details, an investigator may reach out.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.dimmer, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done — Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
