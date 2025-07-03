import 'package:flutter/material.dart';
import 'package:mtm/core/theme/app_palette.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
                gradient: AppPalette.rewardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: AppPalette.contrastLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Rewards',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Earn MTM tokens for authentic listening',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Balance card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.musicGreen.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: AppPalette.contrastMedium,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.info_outline,
                        color: AppPalette.contrastMedium,
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '0.00 MTM',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '≈ \$0.00 USD',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showComingSoonDialog(context, 'Claim Rewards');
                    },
                    icon: const Icon(Icons.redeem),
                    label: const Text('Claim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.musicGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showComingSoonDialog(context, 'Transfer Tokens');
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Transfer'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppPalette.musicBlue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent rewards
            const Text(
              'Recent Rewards',
              style: TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Empty state
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 64,
                      color: AppPalette.contrastMedium,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Start Listening to Earn Rewards',
                      style: TextStyle(
                        color: AppPalette.contrastLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Listen to tracks for at least 30 seconds\nto start earning MTM tokens',
                      style: TextStyle(
                        color: AppPalette.contrastMedium,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // How it works
            const Text(
              'How Rewards Work',
              style: TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const _HowItWorksCard(
              icon: Icons.play_arrow,
              title: 'Listen to Music',
              description: 'Play any track for at least 30 seconds',
              color: AppPalette.musicPurple,
            ),

            const SizedBox(height: 12),

            const _HowItWorksCard(
              icon: Icons.volume_up,
              title: 'Keep Volume Up',
              description: 'Maintain volume above 10% for reward eligibility',
              color: AppPalette.musicBlue,
            ),

            const SizedBox(height: 12),

            const _HowItWorksCard(
              icon: Icons.monetization_on,
              title: 'Earn Tokens',
              description: 'Receive MTM tokens for authentic listening',
              color: AppPalette.musicGreen,
            ),

            const SizedBox(height: 12),

            const _HowItWorksCard(
              icon: Icons.trending_up,
              title: 'Build Streaks',
              description: 'Listen daily for bonus multipliers',
              color: AppPalette.musicOrange,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.backgroundCard,
        title: Text(
          feature,
          style: const TextStyle(color: AppPalette.contrastLight),
        ),
        content: const Text(
          'This feature is coming soon! Keep listening to earn more rewards.',
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

class _HowItWorksCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HowItWorksCard({
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppPalette.contrastMedium,
                    fontSize: 14,
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