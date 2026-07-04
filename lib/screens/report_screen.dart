import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/zones_data.dart';
import '../models/boat_report.dart';
import '../services/app_state.dart';
import '../widgets/notice_banner.dart';
import 'root_shell.dart';

const _boatTypes = [
  'Small wooden fishing boat / ngalawa',
  'Motorised fishing boat (engine-powered)',
  'Dhow (traditional sailing vessel)',
  'Speed boat',
  'Cargo / commercial vessel',
  'Yacht or leisure boat',
  "I'm not sure",
];

const _peopleOptions = ['1–2', '3–5', '6–10', '10+', "Can't tell"];

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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final draft = state.draft;

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Boat')),
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
              child: ElevatedButton(
                onPressed: () {
                  context.findAncestorStateOfType<RootShellState>()?.goTo(3);
                },
                child: const Text('Review My Report →'),
              ),
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

class _ZoneDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _ZoneDropdown({required this.value, required this.onChanged});

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
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.ocean,
          hint: const Text('— Select the zone or nearest area —',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.wave),
          items: [
            ...tanzaniaZones.map(
              (z) => DropdownMenuItem(
                value: z.reportValue,
                child: Text(
                  '${_levelIcon(z.level)} ${z.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const DropdownMenuItem(
              value: "Not sure — described in notes",
              child: Text("I'm not sure — I'll describe it below"),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _levelIcon(ZoneLevel level) {
    switch (level) {
      case ZoneLevel.noEntry:
        return '⛔';
      case ZoneLevel.restricted:
        return '⚠️';
      case ZoneLevel.monitored:
        return '🌿';
    }
  }
}

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

    return Row(
      children: Urgency.values.map((u) {
        final selected = value == u;
        final c = colorFor(u);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: u != Urgency.high ? 8 : 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(u),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                decoration: BoxDecoration(
                  color: selected ? c.withOpacity(0.18) : Colors.transparent,
                  border: Border.all(color: c.withOpacity(selected ? 1 : 0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  u.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c, height: 1.3),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

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
