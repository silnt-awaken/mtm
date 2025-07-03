import 'package:flutter/material.dart';
import 'package:mtm/core/theme/app_palette.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    Icons.leaderboard,
                    size: 48,
                    color: AppPalette.contrastLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Top music listeners this week',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Time filter tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      text: 'Daily',
                      isSelected: true,
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      text: 'Weekly',
                      isSelected: false,
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      text: 'All Time',
                      isSelected: false,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Your rank
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.musicPurple.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppPalette.musicPurple,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Rank',
                          style: TextStyle(
                            color: AppPalette.contrastMedium,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Not ranked yet',
                          style: TextStyle(
                            color: AppPalette.contrastLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '0 MTM',
                    style: TextStyle(
                      color: AppPalette.musicGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Top 3 podium (placeholder)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PodiumCard(rank: 2, name: 'Music Fan', rewards: '2.5K', height: 80),
                _PodiumCard(rank: 1, name: 'Top Listener', rewards: '5.2K', height: 100),
                _PodiumCard(rank: 3, name: 'Beat Lover', rewards: '1.8K', height: 60),
              ],
            ),

            const SizedBox(height: 24),

            // Leaderboard list
            Container(
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Rank',
                          style: TextStyle(
                            color: AppPalette.contrastMedium,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 50),
                        Expanded(
                          child: Text(
                            'Listener',
                            style: TextStyle(
                              color: AppPalette.contrastMedium,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Rewards',
                          style: TextStyle(
                            color: AppPalette.contrastMedium,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppPalette.contrastMedium, height: 1),
                  
                  // Placeholder entries
                  ...List.generate(10, (index) {
                    final rank = index + 4; // Starting from 4th place
                    return _LeaderboardTile(
                      rank: rank,
                      name: 'Music Lover $rank',
                      rewards: '${(1500 - index * 100).toStringAsFixed(0)}',
                      isCurrentUser: false,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Call to action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.music_note,
                    size: 48,
                    color: AppPalette.musicPurple,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Start Climbing the Ranks!',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Listen to music daily and build streaks to earn more rewards and climb the leaderboard.',
                    style: TextStyle(
                      color: AppPalette.contrastMedium,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.musicPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppPalette.contrastLight : AppPalette.contrastMedium,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int rank;
  final String name;
  final String rewards;
  final double height;

  const _PodiumCard({
    required this.rank,
    required this.name,
    required this.rewards,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    IconData rankIcon;
    
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        rankIcon = Icons.military_tech;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        rankIcon = Icons.workspace_premium;
        break;
      default:
        rankColor = AppPalette.contrastMedium;
        rankIcon = Icons.person;
    }

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 2),
          ),
          child: Icon(
            rankIcon,
            color: rankColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: AppPalette.backgroundCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: rankColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: AppPalette.contrastLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${rewards} MTM',
                style: const TextStyle(
                  color: AppPalette.musicGreen,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final String rewards;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.rewards,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppPalette.musicPurple.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: isCurrentUser 
                    ? AppPalette.musicPurple 
                    : AppPalette.contrastMedium,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppPalette.musicPurple.withOpacity(0.3),
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppPalette.contrastLight,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isCurrentUser 
                    ? AppPalette.contrastLight 
                    : AppPalette.contrastMedium,
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '$rewards MTM',
            style: const TextStyle(
              color: AppPalette.musicGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}