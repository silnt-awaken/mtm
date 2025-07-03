import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtm/core/constants/constants.dart';
import 'package:mtm/features/auth/presentation/login_screen.dart';
import 'package:mtm/features/listen/presentation/listen_screen.dart';
import 'package:mtm/features/profile/presentation/profile_screen.dart';
import 'package:mtm/features/artist/presentation/artist_dashboard.dart';
import 'package:mtm/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:mtm/features/rewards/presentation/rewards_screen.dart';
import 'package:mtm/presentation/mtm.dart';
import 'package:mtm/presentation/splash_screen.dart';
import 'package:mtm/services/privy_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Route constants
const String login = AppConstants.loginRoute;
const String home = AppConstants.homeRoute;
const String profile = AppConstants.profileRoute;
const String artist = AppConstants.artistRoute;
const String leaderboard = AppConstants.leaderboardRoute;
const String rewards = AppConstants.rewardsRoute;
const String player = AppConstants.playerRoute;

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: login,
  redirect: (context, state) {
    final isAuthenticated = PrivyService().isAuthenticated();
    final isOnLoginPage = state.uri.toString() == login;

    // If not authenticated and not on login page, redirect to login
    if (!isAuthenticated && !isOnLoginPage) {
      return login;
    }

    // If authenticated and on login page, redirect to home
    if (isAuthenticated && isOnLoginPage) {
      return home;
    }

    // No redirect needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => login,
    ),
    GoRoute(
      path: login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MTMApp(child: child),
      routes: [
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const ListenScreen(),
        ),
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: artist,
          name: 'artist',
          builder: (context, state) => const ArtistDashboard(),
        ),
        GoRoute(
          path: leaderboard,
          name: 'leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: rewards,
          name: 'rewards',
          builder: (context, state) => const RewardsScreen(),
        ),
        GoRoute(
          path: '$player/:trackId',
          name: 'player',
          builder: (context, state) {
            final trackId = state.pathParameters['trackId']!;
            return ListenScreen(initialTrackId: trackId);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you are looking for does not exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);