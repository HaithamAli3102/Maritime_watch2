import 'package:flutter/material.dart';
import 'cover_screen.dart';
import 'location_screen.dart';
import 'zones_screen.dart';
import 'report_screen.dart';
import 'review_screen.dart';
import 'more_screen.dart';
import '../widgets/shared_widgets.dart';

/// Hosts the bottom-nav tabs. The Cover screen is shown first, standalone
/// (no bottom nav), then handing off into this shell once the citizen taps
/// "Report a Boat Now" or "View Restricted Zones".
class RootShell extends StatefulWidget {
  final int initialIndex;
  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => RootShellState();
}

class RootShellState extends State<RootShell> {
  late int _index = widget.initialIndex;

  void goTo(int index) => setState(() => _index = index);
  static const _screens = [
    LocationScreen(),
    ZonesScreen(),
    ReportScreen(),
    ReviewScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: MaritimeBottomNav(
        currentIndex: _index,
        onTap: goTo,
      ),
    );
  }
}

/// Entry route — the standalone cover/splash screen.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const CoverScreen();
  }
}
