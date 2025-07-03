import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/features/profile/bloc/profile_bloc.dart';
import 'package:mtm/services/privy_service.dart';

class MTMAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MTMAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppPalette.musicGradient),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.music_note,
            color: AppPalette.contrastLight,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text(
            'MTM',
            style: TextStyle(
              color: AppPalette.contrastLight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppPalette.contrastLight,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.user.formattedTotalRewards} MTM',
                      style: const TextStyle(
                        color: AppPalette.contrastLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: AppPalette.contrastLight),
      actions: [
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return PopupMenuButton<String>(
              icon: const Icon(
                Icons.account_circle,
                color: AppPalette.contrastLight,
                size: 28,
              ),
              color: AppPalette.backgroundCard,
              onSelected: (value) => _handleMenuSelection(context, value),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'wallet',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: AppPalette.contrastLight,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wallet',
                                style: TextStyle(
                                  color: AppPalette.contrastLight,
                                ),
                              ),
                              Text(
                                _getWalletStatus(),
                                style: const TextStyle(
                                  color: AppPalette.contrastMedium,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: AppPalette.contrastLight),
                          SizedBox(width: 8),
                          Text(
                            'Profile',
                            style: TextStyle(color: AppPalette.contrastLight),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: AppPalette.contrastLight),
                          SizedBox(width: 8),
                          Text(
                            'Settings',
                            style: TextStyle(color: AppPalette.contrastLight),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: AppPalette.error),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(color: AppPalette.error),
                          ),
                        ],
                      ),
                    ),
                  ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _getWalletStatus() {
    final privyService = PrivyService();
    if (!privyService.isAuthenticated()) {
      return 'Not connected';
    }

    final walletAddress = privyService.walletAddress;
    if (walletAddress == null) {
      return 'No wallet';
    }

    return '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}';
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'wallet':
        _showWalletDialog(context);
        break;
      case 'profile':
        // Navigate to profile
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showWalletDialog(BuildContext context) {
    final privyService = PrivyService();
    //final walletInfo = privyService.walletInfo;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppPalette.backgroundCard,
            title: const Text(
              'Wallet Information',
              style: TextStyle(color: AppPalette.contrastLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (walletInfo != null) ...[
                //   _InfoRow('Address', walletInfo['address'] ?? 'Unknown'),
                //   _InfoRow('Type', walletInfo['type'] ?? 'Unknown'),
                //   _InfoRow('Network', 'Solana'),
                // ]

                // else ...[
                const Text(
                  'No wallet connected',
                  style: TextStyle(color: AppPalette.contrastMedium),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    //await privyService.createWallet();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.musicPurple,
                  ),
                  child: const Text('Create Wallet'),
                ),
              ],
              //],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppPalette.musicPurple),
                ),
              ),
            ],
          ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppPalette.backgroundCard,
            title: const Text(
              'Settings',
              style: TextStyle(color: AppPalette.contrastLight),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Settings coming soon!',
                  style: TextStyle(color: AppPalette.contrastMedium),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppPalette.musicPurple),
                ),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppPalette.contrastMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppPalette.contrastLight),
            ),
          ),
        ],
      ),
    );
  }
}
