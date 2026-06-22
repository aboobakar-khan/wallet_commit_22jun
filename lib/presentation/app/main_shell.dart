import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../history/history_screen.dart';
import '../sadaqah/sadaqah_screen.dart';
import '../today/today_screen.dart';
import '../wallet/wallet_screen.dart';
import '../widgets/app_icons.dart';
import '../widgets/sukoon_nav_bar.dart';

/// The signed-in home — four destinations, worship-first in order. Settings and
/// the dev panel hang off the Today top bar, not the nav, to keep it quiet.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _items = [
    NavItem(AppIcons.today, 'Today'),
    NavItem(AppIcons.history, 'History'),
    NavItem(AppIcons.wallet, 'Wallet'),
    NavItem(AppIcons.giving, 'Giving'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: IndexedStack(
        index: _index,
        children: const [
          TodayScreen(),
          HistoryScreen(),
          WalletScreen(),
          SadaqahScreen(),
        ],
      ),
      bottomNavigationBar: SukoonNavBar(
        index: _index,
        items: _items,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
