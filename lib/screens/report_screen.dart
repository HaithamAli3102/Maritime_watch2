import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maritime_watch/screens/review_screen.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../data/zones_data.dart';
import '../models/boat_report.dart';
import '../services/app_state.dart';
import '../widgets/notice_banner.dart';
import '../controllers/zoness_controller.dart';
import 'root_shell.dart';
import '../controllers/report_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _notesCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _contactOpen = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _notesCtrl.dispose();
    _colorCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (file != null && mounted) {
        context.read<AppState>().addPhoto(File(file.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't access camera or gallery.")),
        );
      }
    }
  }

  final _peopleOptions = ['1–2', '3–5', '6–10', '10+', "Can't tell"];
  final _boatTypes = [
    'Fishing boat (small)',
    'Fishing boat (large)',
    'Fishing vessel (industrial)',
    'Motorised dhow',
    'Traditional dhow (sail)',
    'Speedboat',
    'Yacht / Pleasure craft',
    'Cargo ship',
    'Tanker',
    'Passenger ferry',
    'Container ship',
    'Tugboat',
    'Patrol boat',
    'Research vessel',
    'Floating platform',
    'Barge',
    'Catamaran',
    'Kayak / Canoe',
    'Jetski',
    'Other powered vessel',
    "Can't tell / Not sure",
  ];

  final reportController = Get.put(ReportController());
  final zoneController = Get.put(ZonesController());

  // Helper method to parse people count
  int _parsePeopleCount(String? peopleString) {
    if (peopleString == null) return 1;

    switch (peopleString) {
      case '1–2':
        return 2;
      case '3–5':
        return 5;
      case '6–10':
        return 10;
      case '10+':
        return 11;
      case "Can't tell":
        return 0;
      default:
        return 1;
    }
  }

  // Helper method to get zone data
  MaritimeZone? _getZoneData(String? zoneValue) {
    if (zoneValue == null) return null;
    print("hazaId : $zoneValue");
    try {
      return tanzaniaZones.firstWhere(
            (z) => z.reportValue == zoneValue,
        orElse: () => tanzaniaZones.first,
      );
    } catch (e) {
      return null;
    }
  }

  // Method to submit report
  Future<void> _submitReport() async {

    final state = context.read<AppState>();
    final draft = state.draft;

    // Validate required fields
    // if (draft.zoneValue == null || draft.zoneValue!.isEmpty) {
    //   Get.snackbar(
    //     'Validation Error',
    //     'Please select a restricted zone.',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red.shade700,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }
    // print("object");
    // if (draft.boatType == null || draft.boatType!.isEmpty) {
    //   Get.snackbar(
    //     'Validation Error',
    //     'Please select a boat type.',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red.shade700,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    // Get zone data
    final zone = _getZoneData(draft.zoneValue);
    print('ssssxxx');
    if (zone == null) {

      print('ssss');
      Get.snackbar(
        'Error',
        'Invalid zone selected. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }
    print("object");
    // Map urgency to ID
    int urgencyId;
    switch (draft.urgency) {
      case Urgency.low:
        urgencyId = 1;
        break;
      case Urgency.medium:
        urgencyId = 2;
        break;
      case Urgency.high:
        urgencyId = 3;
        break;
    }

    // Format date
    final formattedDate = draft.sightedAt.toIso8601String();

    // Get photo name if exists
    String photoName = '';

    if (draft.photos.isNotEmpty) {
      photoName = draft.photos.first.path.split('/').last;
    }

// Change this:
 final d =draft.sightedAt.toIso8601String();

// To this (if server expects Y-m-d H:i:s):
    final dd = '${draft.sightedAt.year}-${draft.sightedAt.month.toString().padLeft(2, '0')}-${draft.sightedAt.day.toString().padLeft(2, '0')} ${draft.sightedAt.hour.toString().padLeft(2, '0')}:${draft.sightedAt.minute.toString().padLeft(2, '0')}:00';

// Or this (if server expects Y-m-d\TH:i:s.u\Z):
    final dx = '${draft.sightedAt.toIso8601String().split('.').first}Z';

    print(d);
    print(dd);
    print(dx);
    try {
      // Call the API
      await reportController.addReport(
        date: formattedDate,
        latitude: "-6.7565958",
        longitude: '39.193252',
        address: zone.name,
        zoneId: '019f23d1-6f70-71e2-a651-6fa5549627ac',
        color: draft.boatColor ?? 'Unknown',
        numberOfPeople: _parsePeopleCount(draft.peopleOnboard),
        description: draft.notes ?? 'No description provided',
        photo: photoName,
        name: draft.contactName?.isNotEmpty == true ? draft.contactName! : 'Anonymous',
        phone: draft.contactPhone ?? '',
        urgencyId: urgencyId,
      );
      Get.to(()=>ReviewScreen());

      // If successful, clear draft and navigate
      if (reportController.isReportAdded) {
        // state.clearDraft();
        context.findAncestorStateOfType<RootShellState>()?.goTo(0);

        Get.snackbar(
          'Success',
          'Your report has been submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      // Error is already handled in the controller
      print('Error submitting report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final draft = state.draft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Boat'),
        actions: [
          // Loading indicator
          Obx(() {
            if (reportController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            const _StepBar(),
            const NoticeBanner(
              kind: NoticeKind.soft,
              icon: '🛡️',
              text: 'Your safety first. Stay at a safe distance. Never approach the vessel yourself.',
            ),

            // ── When ──
            const _FieldLabel('📅', 'When did you see it?'),
            _DateTimeField(
              value: draft.sightedAt,
              onChanged: (dt) => setState(() => draft.sightedAt = dt),
            ),
            const SizedBox(height: 18),

            // ── Zone ──
            const _FieldLabel('📍', 'Which restricted zone?'),
            _ZoneDropdown(
              value: draft.zoneValue,
              onChanged: (v) => state.updateZone(v),
            ),
            const SizedBox(height: 6),
            const Text(
              'The zone coordinates are automatically included in your report to '
                  'help the Marine Department locate the area.',
              style: TextStyle(fontSize: 11, color: AppColors.dimmer, height: 1.5),
            ),
            const SizedBox(height: 18),

            // ── Boat type ──
            const _FieldLabel('🛥️', 'What kind of boat?'),
            _Dropdown<String>(
              value: draft.boatType,
              hint: '— Best match —',
              items: _boatTypes,
              onChanged: (v) => state.updateBoatType(v),
            ),
            const SizedBox(height: 18),

            // ── Color + people ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('', 'Colour'),
                      TextField(
                        controller: _colorCtrl,
                        decoration: const InputDecoration(hintText: 'e.g. Blue, white…'),
                        onChanged: (v) => draft.boatColor = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('', 'People onboard'),
                      _Dropdown<String>(
                        value: draft.peopleOnboard,
                        hint: '1–2',
                        items: _peopleOptions,
                        onChanged: (v) => setState(() => draft.peopleOnboard = v ?? '1–2'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Notes ──
            const _FieldLabel('✍️', 'Describe what you saw'),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. A blue motorised fishing boat was anchored inside the reef. '
                    'Two men appeared to be fishing with nets. I observed from the shore '
                    'for about 10 minutes…',
              ),
              onChanged: (v) => draft.notes = v,
            ),
            const SizedBox(height: 6),
            const Text('Plain language is fine. Any detail helps.',
                style: TextStyle(fontSize: 11, color: AppColors.dimmer)),
            const SizedBox(height: 20),

            // ── Urgency ──
            const SectionLabel('How urgent is this?'),
            _UrgencyRow(value: draft.urgency, onChanged: state.updateUrgency),
            const SizedBox(height: 6),

            // ── Photo evidence ──
            const SectionLabel('📷 Photo Evidence'),
            const NoticeBanner(
              kind: NoticeKind.soft,
              icon: '📸',
              text: "Add photos as evidence — only if it's safe to do so. Take a new photo "
                  'or choose from your gallery.',
            ),
            _PhotoGrid(
              photos: draft.photos,
              onAddCamera: () => _pickImage(ImageSource.camera),
              onAddGallery: () => _pickImage(ImageSource.gallery),
              onRemove: state.removePhoto,
            ),
            const SizedBox(height: 6),
            const Text('Up to 5 photos accepted.', style: TextStyle(fontSize: 11, color: AppColors.dimmer)),
            const SizedBox(height: 22),

            // ── Optional contact ──
            _ContactSection(
              open: _contactOpen,
              onToggle: () => setState(() => _contactOpen = !_contactOpen),
              nameCtrl: _nameCtrl,
              phoneCtrl: _phoneCtrl,
              addressCtrl: _addressCtrl,
              onChanged: () => state.setContact(
                name: _nameCtrl.text,
                phone: _phoneCtrl.text,
                address: _addressCtrl.text,
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: reportController.isLoading.value ? null : _submitReport,
                child: reportController.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text('Review Report →'),
              )),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can send without filling in contact details.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.dimmer),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Sub-widgets ─────────────────────────

class _StepBar extends StatelessWidget {
  const _StepBar();

  @override
  Widget build(BuildContext context) {
    Widget circle(String label, {required bool done, required bool now}) {
      return Column(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.sky : (now ? AppColors.white : Colors.white.withOpacity(0.1)),
            ),
            child: done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: now ? AppColors.navy : AppColors.dimmer)),
          ),
        ],
      );
    }

    Widget line(bool done) => Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: done ? AppColors.sky : Colors.white.withOpacity(0.1),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 18, top: 2),
      child: Row(
        children: [
          circle('1', done: true, now: false),
          line(true),
          circle('2', done: false, now: true),
          line(false),
          circle('3', done: false, now: false),
          line(false),
          circle('4', done: false, now: false),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String icon;
  final String text;
  const _FieldLabel(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          if (icon.isNotEmpty) ...[Text(icon, style: const TextStyle(fontSize: 13)), const SizedBox(width: 6)],
          Text(
            text.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.wave, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.wave, letterSpacing: 1.4),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const _DateTimeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label =
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}  '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
        );
        if (date == null) return;
        if (!context.mounted) return;
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value));
        if (time == null) return;
        onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.wave),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14, color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Zone Dropdown ─────────────────────────

class _ZoneDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _ZoneDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ZonesController zoneController = Get.find<ZonesController>();

    return Obx(() {
      // Show loading state
      if (zoneController.isLoading.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.wave),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading zones...',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        );
      }

      // Show error state
      if (zoneController.hashError) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  zoneController.errorMessage.value,
                  style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: zoneController.refreshZones,
                child: const Text('Retry', style: TextStyle(color: AppColors.wave)),
              ),
            ],
          ),
        );
      }

      // Build dropdown with zones from API
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AppColors.ocean,
            hint: Text(
              zoneController.hasZones
                  ? '— Select the zone or nearest area —'
                  : '— No zones available —',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.wave),
            items: [
              // API Zones
              ...zoneController.zones.map(
                    (zone) => DropdownMenuItem(
                  value: zone.name,
                  child: Text(
                    '${_getZoneIcon(zone.type.toString())} ${zone.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Manual entry option
              const DropdownMenuItem(
                value: "Not sure — described in notes",
                child: Text("I'm not sure — I'll describe it below"),
              ),
            ],
            onChanged: zoneController.hasZones ? onChanged : null,
          ),
        ),
      );
    });
  }

  String _getZoneIcon(String type) {
    switch (type.toLowerCase()) {
      case 'restricted':
        return '⛔';
      case 'monitored':
        return '🌿';
      case 'danger':
        return '⚠️';
      case 'inactive':
        return '⏸️';
      default:
        return '📍';
    }
  }
}

// ───────────────────────── Generic Dropdown ─────────────────────────

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  const _Dropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.ocean,
          hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 14)),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.wave),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ───────────────────────── Urgency Row ─────────────────────────

class _UrgencyRow extends StatelessWidget {
  final Urgency value;
  final ValueChanged<Urgency> onChanged;
  const _UrgencyRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color colorFor(Urgency u) {
      switch (u) {
        case Urgency.low:
          return AppColors.wave;
        case Urgency.medium:
          return const Color(0xFFFFB74D);
        case Urgency.high:
          return const Color(0xFFEF9A9A);
      }
    }

    String urgencyIcon(Urgency u) {
      switch (u) {
        case Urgency.low:
          return 'ℹ️';
        case Urgency.medium:
          return '⚠️';
        case Urgency.high:
          return '🚨';
      }
    }

    String urgencyDescription(Urgency u) {
      switch (u) {
        case Urgency.low:
          return 'Low priority';
        case Urgency.medium:
          return 'Medium priority';
        case Urgency.high:
          return 'High priority';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: Urgency.values.map((u) {
            final selected = value == u;
            final c = colorFor(u);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: u != Urgency.high ? 8 : 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(u),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: selected ? c.withOpacity(0.18) : Colors.transparent,
                      border: Border.all(
                        color: selected ? c : c.withOpacity(0.3),
                        width: selected ? 2.0 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: c.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          urgencyIcon(u),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          urgencyDescription(u),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: c,
                            height: 1.3,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 2,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorFor(value).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorFor(value).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                'Selected: ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.dimmer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorFor(value),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorFor(value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Photo Grid ─────────────────────────

class _PhotoGrid extends StatelessWidget {
  final List<File> photos;
  final VoidCallback onAddCamera;
  final VoidCallback onAddGallery;
  final ValueChanged<int> onRemove;
  const _PhotoGrid({
    required this.photos,
    required this.onAddCamera,
    required this.onAddGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ...photos.asMap().entries.map((e) => _PhotoThumb(file: e.value, onRemove: () => onRemove(e.key))),
      if (photos.length < 5) _AddTile(icon: Icons.camera_alt, label: 'Take Photo', onTap: onAddCamera),
      if (photos.length < 4) _AddTile(icon: Icons.photo_library, label: 'Gallery', onTap: onAddGallery),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: tiles,
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sky.withOpacity(0.05),
          border: Border.all(color: AppColors.sky.withOpacity(0.35), width: 1.5, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.wave, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.wave)),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(file, fit: BoxFit.cover),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Contact Section ─────────────────────────

class _ContactSection extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final VoidCallback onChanged;

  const _ContactSection({
    required this.open,
    required this.onToggle,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.14), style: BorderStyle.solid, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('🙋', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
                            children: [
                              TextSpan(text: 'Your contact details  '),
                              TextSpan(
                                text: '(optional)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.dimmer),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Only needed if investigators want to follow up. You can still send without this.',
                          style: TextStyle(fontSize: 12, color: AppColors.dim, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right, color: AppColors.dimmer),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const NoticeBanner(
                    kind: NoticeKind.info,
                    icon: '🔒',
                    text: 'Your details are kept confidential and used only by Marine Department '
                        'investigators if they need to contact you about this specific report.',
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const _FieldLabel('', 'Full Name'),
                  ),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. Juma Hassan'),
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const _FieldLabel('', 'Phone Number'),
                  ),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+255 7XX XXX XXX'),
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const _FieldLabel('', 'Address / Area'),
                  ),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. Msasani, Dar es Salaam'),
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Your neighbourhood or nearest landmark is enough.',
                        style: TextStyle(fontSize: 11, color: AppColors.dimmer)),
                  ),
                ],
              ),
            ),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

}