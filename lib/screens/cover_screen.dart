import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'root_shell.dart';

class CoverScreen extends StatelessWidget {
  const CoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientCover),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _Logo(),
                        const SizedBox(height: 18),
                        const Text(
                          'MARINE DEPARTMENT — TANZANIA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.wave,
                            letterSpacing: 3.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'See a boat where it '),
                              TextSpan(
                                text: "shouldn't be?",
                                style: TextStyle(color: AppColors.wave),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Help protect Tanzania's coastal waters. Spot a vessel in a "
                          'restricted zone — report it in seconds. No account needed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.dim, height: 1.6),
                        ),
                        const SizedBox(height: 26),
                        const _HowItWorksCard(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.campaign, size: 20),
                    label: const Text('Report a Boat Now', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color.fromARGB(255, 31, 48, 137),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.wave,
                      side: BorderSide(color: AppColors.wave.withOpacity(0.35), width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 1)),
                    ),
                    child: const Text('View Restricted Zones', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '🔒  Anonymous · No login required',
                  style: TextStyle(fontSize: 11, color: AppColors.dimmer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 38, 41, 229), Color.fromARGB(255, 14, 72, 220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color.fromARGB(255, 8, 17, 184).withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(color: const Color.fromARGB(255, 42, 42, 164).withOpacity(0.22), blurRadius: 40, spreadRadius: 4),
        ],
      ),
      child: const Center(child: Text('⚓', style: TextStyle(fontSize: 38))),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW IT WORKS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.wave,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          const _Step(
            number: '1',
            text: 'Open the app — your location is detected automatically',
          ),
          const SizedBox(height: 12),
          const _Step(
            number: '2',
            text: 'Describe the boat — select the zone, type, colour, add a photo',
          ),
          const SizedBox(height: 12),
          const _Step(
            number: '3',
            text: 'Send the report — authorities are notified immediately',
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sky.withOpacity(0.18),
            border: Border.all(color: AppColors.sky.withOpacity(0.32)),
          ),
          child: Text(
            number,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.wave),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: text.split(' — ')[0],
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
              children: [
                TextSpan(
                  text: ' — ${text.split(' — ').sublist(1).join(' — ')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.dim),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
