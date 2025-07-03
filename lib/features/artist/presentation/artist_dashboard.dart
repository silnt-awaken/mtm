import 'package:flutter/material.dart';
import 'package:mtm/core/theme/app_palette.dart';

class ArtistDashboard extends StatelessWidget {
  const ArtistDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppPalette.musicGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.mic,
                    size: 48,
                    color: AppPalette.contrastLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Artist Dashboard',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your music and track earnings',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats overview
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Plays',
                    value: '0',
                    icon: Icons.play_arrow,
                    color: AppPalette.musicBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Rewards Earned',
                    value: '0 MTM',
                    icon: Icons.monetization_on,
                    color: AppPalette.musicGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Tracks',
                    value: '0',
                    icon: Icons.music_note,
                    color: AppPalette.musicPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Listeners',
                    value: '0',
                    icon: Icons.people,
                    color: AppPalette.musicOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Upload Track',
                    subtitle: 'Add new music',
                    icon: Icons.upload,
                    color: AppPalette.musicPurple,
                    onTap: () => _showComingSoon(context, 'Upload Track'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    title: 'Analytics',
                    subtitle: 'View insights',
                    icon: Icons.analytics,
                    color: AppPalette.musicBlue,
                    onTap: () => _showComingSoon(context, 'Analytics'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Your tracks section
            const Text(
              'Your Tracks',
              style: TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Empty state for tracks
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.contrastMedium.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.music_note,
                    size: 64,
                    color: AppPalette.contrastMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tracks uploaded yet',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload your first track to start earning rewards from listeners',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showComingSoon(context, 'Upload Track'),
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Your First Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.musicPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Artist guidelines
            const Text(
              'Artist Guidelines',
              style: TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const _GuidelineCard(
              icon: Icons.high_quality,
              title: 'High Quality Audio',
              description: 'Upload tracks in at least 320kbps MP3 or lossless formats',
              color: AppPalette.musicBlue,
            ),

            const SizedBox(height: 12),

            const _GuidelineCard(
              icon: Icons.copyright,
              title: 'Original Content',
              description: 'Only upload music you own or have rights to distribute',
              color: AppPalette.musicGreen,
            ),

            const SizedBox(height: 12),

            const _GuidelineCard(
              icon: Icons.info,
              title: 'Complete Metadata',
              description: 'Provide accurate track info, genre, and cover art',
              color: AppPalette.musicOrange,
            ),

            const SizedBox(height: 12),

            const _GuidelineCard(
              icon: Icons.policy,
              title: 'Community Standards',
              description: 'Follow our community guidelines for content appropriateness',
              color: AppPalette.musicPink,
            ),

            const SizedBox(height: 32),

            // Support section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check out our artist resources or contact support',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showComingSoon(context, 'Artist Guide'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppPalette.musicPurple),
                          ),
                          child: const Text('Artist Guide'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showComingSoon(context, 'Contact Support'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.musicPurple,
                          ),
                          child: const Text('Contact Support'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.backgroundCard,
        title: Text(
          feature,
          style: const TextStyle(color: AppPalette.contrastLight),
        ),
        content: const Text(
          'This feature is coming soon! We\'re working hard to bring you the best artist experience.',
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
            style: const TextStyle(
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              title,
              style: const TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppPalette.contrastMedium,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidelineCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _GuidelineCard({
    required this.icon,
    required this.title,
    required this.description,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPalette.contrastLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppPalette.contrastMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}