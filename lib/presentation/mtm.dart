import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/presentation/mtm_drawer.dart';
import 'package:mtm/shared/widgets/mtm_app_bar.dart';

class MTMApp extends StatelessWidget {
  final Widget child;
  
  const MTMApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundDark,
      appBar: const MTMAppBar(),
      drawer: const MTMDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPalette.backgroundDark,
              AppPalette.backgroundCard,
            ],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class MTMBottomNavigationBar extends StatelessWidget {
  const MTMBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppPalette.musicGradient,
        boxShadow: [
          BoxShadow(
            color: AppPalette.musicPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppPalette.contrastLight,
        unselectedItemColor: AppPalette.contrastMedium,
        currentIndex: _getCurrentIndex(currentLocation),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Listen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/leaderboard')) return 1;
    if (location.startsWith('/rewards')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/leaderboard');
        break;
      case 2:
        context.go('/rewards');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}