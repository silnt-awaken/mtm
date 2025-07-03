import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/features/profile/bloc/profile_bloc.dart';
import 'package:mtm/services/privy_service.dart';

class MTMDrawer extends StatelessWidget {
  const MTMDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppPalette.backgroundCard,
      child: Column(
        children: [
          // Header with user info
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppPalette.musicGradient,
                ),
                accountName: Text(
                  state is ProfileLoaded ? state.user.displayName : 'Music Lover',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.contrastLight,
                  ),
                ),
                accountEmail: Text(
                  state is ProfileLoaded && state.user.email != null
                      ? state.user.email!
                      : 'Welcome to MTM',
                  style: const TextStyle(
                    color: AppPalette.contrastMedium,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppPalette.backgroundCard,
                  child: Icon(
                    Icons.music_note,
                    color: AppPalette.musicPurple,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () => _navigateTo(context, '/home'),
                ),
                _DrawerItem(
                  icon: Icons.music_note,
                  title: 'Listen & Earn',
                  onTap: () => _navigateTo(context, '/home'),
                ),
                _DrawerItem(
                  icon: Icons.leaderboard,
                  title: 'Leaderboard',
                  onTap: () => _navigateTo(context, '/leaderboard'),
                ),
                _DrawerItem(
                  icon: Icons.account_balance_wallet,
                  title: 'My Rewards',
                  onTap: () => _navigateTo(context, '/rewards'),
                ),
                _DrawerItem(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () => _navigateTo(context, '/profile'),
                ),
                const Divider(color: AppPalette.contrastMedium),
                _DrawerItem(
                  icon: Icons.mic,
                  title: 'Artist Dashboard',
                  onTap: () => _navigateTo(context, '/artist'),
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _showHelpDialog(context),
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  title: 'About MTM',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          
          // Bottom section with logout
          const Divider(color: AppPalette.contrastMedium),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: AppPalette.error,
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    context.go(route);
  }

  void _showHelpDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.backgroundCard,
        title: const Text(
          'Help & Support',
          style: TextStyle(color: AppPalette.contrastLight),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to earn rewards:',
              style: TextStyle(
                color: AppPalette.contrastLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Listen to music for at least 30 seconds\n'
              '• Keep volume above 10%\n'
              '• Build daily listening streaks\n'
              '• Discover new artists and tracks',
              style: TextStyle(color: AppPalette.contrastMedium),
            ),
            SizedBox(height: 16),
            Text(
              'Need more help? Contact us at support@musicthatmatters.app',
              style: TextStyle(color: AppPalette.contrastMedium),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppPalette.musicPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer
    showAboutDialog(
      context: context,
      applicationName: 'MTM - Music That Matters',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.music_note,
        color: AppPalette.musicPurple,
        size: 48,
      ),
      children: const [
        Text(
          'MTM rewards authentic music listeners with SPL tokens on the Solana blockchain. '
          'Discover new music, support artists, and earn rewards for your genuine listening.',
          style: TextStyle(color: AppPalette.contrastMedium),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.backgroundCard,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppPalette.contrastLight),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppPalette.contrastMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppPalette.contrastMedium),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PrivyService().logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppPalette.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppPalette.contrastLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppPalette.contrastLight,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      hoverColor: AppPalette.musicPurple.withOpacity(0.1),
    );
  }
}