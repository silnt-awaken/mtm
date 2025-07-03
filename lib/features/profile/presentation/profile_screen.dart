import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/features/profile/bloc/profile_bloc.dart';
import 'package:mtm/services/privy_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppPalette.musicPurple),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppPalette.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: const TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppPalette.contrastMedium),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppPalette.musicGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppPalette.contrastLight,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppPalette.musicPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state is ProfileLoaded
                            ? state.user.displayName
                            : 'Music Lover',
                        style: const TextStyle(
                          color: AppPalette.contrastLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state is ProfileLoaded && state.user.email != null)
                        Text(
                          state.user.email!,
                          style: const TextStyle(
                            color: AppPalette.contrastMedium,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats cards
                if (state is ProfileLoaded) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Rewards',
                          value: '${state.user.formattedTotalRewards} MTM',
                          icon: Icons.monetization_on,
                          color: AppPalette.musicGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Listen Time',
                          value: state.user.formattedListenTime,
                          icon: Icons.access_time,
                          color: AppPalette.musicBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Daily Streak',
                          value: '${state.user.dailyStreak} days',
                          icon: Icons.local_fire_department,
                          color: AppPalette.musicOrange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Tracks Played',
                          value: '${state.user.tracksPlayed}',
                          icon: Icons.music_note,
                          color: AppPalette.musicPink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],

                // Wallet section
                _SectionCard(
                  title: 'Wallet',
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Status',
                        value:
                            PrivyService().hasWallet
                                ? 'Connected'
                                : 'Not Connected',
                        valueColor:
                            PrivyService().hasWallet
                                ? AppPalette.success
                                : AppPalette.warning,
                      ),
                      if (PrivyService().hasWallet)
                        _InfoRow(
                          label: 'Address',
                          value:
                              PrivyService().walletAddress?.substring(0, 16) ??
                              'Unknown',
                        ),
                      const SizedBox(height: 16),
                      if (!PrivyService().hasWallet)
                        ElevatedButton(
                          onPressed: () async {
                            //await PrivyService().createWallet();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.musicPurple,
                          ),
                          child: const Text('Create Wallet'),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Settings section
                _SectionCard(
                  title: 'Settings',
                  child: Column(
                    children: [
                      _SettingsTile(
                        title: 'Notifications',
                        subtitle: 'Receive reward notifications',
                        value:
                            state is ProfileLoaded
                                ? state.user.notificationsEnabled
                                : true,
                        onChanged: (value) {
                          // Handle notification toggle
                        },
                      ),
                      _SettingsTile(
                        title: 'Share Listening',
                        subtitle: 'Show your activity to friends',
                        value:
                            state is ProfileLoaded
                                ? state.user.shareListening
                                : false,
                        onChanged: (value) {
                          // Handle sharing toggle
                        },
                      ),
                      _SettingsTile(
                        title: 'Auto Play',
                        subtitle: 'Automatically play next track',
                        value:
                            state is ProfileLoaded ? state.user.autoPlay : true,
                        onChanged: (value) {
                          // Handle auto play toggle
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Artist section
                _SectionCard(
                  title: 'Artist Features',
                  child: Column(
                    children: [
                      if (state is ProfileLoaded && state.user.isArtist) ...[
                        _InfoRow(
                          label: 'Artist Status',
                          value:
                              state.user.artistProfile?.verificationStatus ??
                              'Unknown',
                          valueColor: _getVerificationColor(
                            state.user.artistProfile?.verificationStatus,
                          ),
                        ),
                        _InfoRow(
                          label: 'Artist Name',
                          value:
                              state.user.artistProfile?.artistName ?? 'Unknown',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to artist dashboard
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.musicPurple,
                          ),
                          child: const Text('Artist Dashboard'),
                        ),
                      ] else ...[
                        const Text(
                          'Want to share your music and earn from plays?',
                          style: TextStyle(color: AppPalette.contrastMedium),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _showArtistRegistrationDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.musicPurple,
                          ),
                          child: const Text('Become an Artist'),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getVerificationColor(String? status) {
    switch (status) {
      case 'verified':
        return AppPalette.success;
      case 'pending':
        return AppPalette.warning;
      case 'rejected':
        return AppPalette.error;
      default:
        return AppPalette.contrastMedium;
    }
  }

  void _showArtistRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppPalette.backgroundCard,
            title: const Text(
              'Become an Artist',
              style: TextStyle(color: AppPalette.contrastLight),
            ),
            content: const Text(
              'Artist registration coming soon! You\'ll be able to upload your music and earn rewards from listeners.',
              style: TextStyle(color: AppPalette.contrastMedium),
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppPalette.contrastLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppPalette.contrastMedium,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppPalette.contrastLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.contrastMedium)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppPalette.contrastLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: AppPalette.contrastLight),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppPalette.contrastMedium),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppPalette.musicPurple,
      ),
    );
  }
}
