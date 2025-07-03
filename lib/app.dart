import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/features/auth/presentation/login_screen.dart';
import 'package:mtm/features/listen/bloc/listen_bloc.dart';
import 'package:mtm/features/listen/data/listen_repository.dart';
// import 'package:mtm/features/rewards/bloc/rewards_bloc.dart';
// import 'package:mtm/features/rewards/data/rewards_repository.dart';
import 'package:mtm/features/profile/bloc/profile_bloc.dart';
import 'package:mtm/features/profile/data/profile_repository.dart';
// import 'package:mtm/features/artist/bloc/artist_bloc.dart';
// import 'package:mtm/features/artist/data/artist_repository.dart';
// import 'package:mtm/features/leaderboard/bloc/leaderboard_bloc.dart';
// import 'package:mtm/features/leaderboard/data/leaderboard_repository.dart';
// import 'package:mtm/services/privy_service.dart';
import 'package:mtm/services/user_service.dart';
import 'package:mtm/services/audio_service.dart';
import 'package:mtm/presentation/mtm.dart';

class App extends HookWidget {
  final GoRouter router;
  const App({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ListenRepository>(create: (_) => ListenRepository()),
        // RepositoryProvider<RewardsRepository>(
        //   create: (_) => RewardsRepository(),
        // ),
        RepositoryProvider<ProfileRepository>(
          create:
              (_) => ProfileRepository(
                secureStorage: const FlutterSecureStorage(),
              ),
        ),
        // RepositoryProvider<ArtistRepository>(create: (_) => ArtistRepository()),
        // RepositoryProvider<LeaderboardRepository>(
        //   create: (_) => LeaderboardRepository(),
        // ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ListenBloc>(
                create:
                    (_) => ListenBloc(
                      listenRepository: context.read<ListenRepository>(),
                      audioService: AudioService(),
                    ),
              ),
              // BlocProvider<RewardsBloc>(
              //   create:
              //       (_) => RewardsBloc(
              //         rewardsRepository: context.read<RewardsRepository>(),
              //       ),
              // ),
              BlocProvider<ProfileBloc>(
                create:
                    (_) => ProfileBloc(
                      profileRepository: context.read<ProfileRepository>(),
                    ),
              ),
              // BlocProvider<ArtistBloc>(
              //   create:
              //       (_) => ArtistBloc(
              //         artistRepository: context.read<ArtistRepository>(),
              //       ),
              // ),
              // BlocProvider<LeaderboardBloc>(
              //   create:
              //       (_) => LeaderboardBloc(
              //         leaderboardRepository:
              //             context.read<LeaderboardRepository>(),
              //       ),
              // ),
            ],
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'MTM - Music That Matters',
              theme: ThemeData(
                primaryColor: AppPalette.musicPurple,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppPalette.musicPurple,
                ),
                scaffoldBackgroundColor: Colors.transparent,
                extensions: <ThemeExtension<dynamic>>[AppColors()],
                textTheme: GoogleFonts.interTextTheme().apply(
                  bodyColor: AppPalette.contrastLight,
                  displayColor: AppPalette.contrastLight,
                  decorationColor: AppPalette.contrastLight,
                ),
              ),
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}
