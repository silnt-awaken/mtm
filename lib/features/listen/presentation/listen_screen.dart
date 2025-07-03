import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/features/listen/bloc/listen_bloc.dart';
import 'package:mtm/shared/track/track.dart';

class ListenScreen extends StatefulWidget {
  final String? initialTrackId;
  
  const ListenScreen({super.key, this.initialTrackId});

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ListenBloc>().add(ListenInitializeEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tracks, artists...',
                    hintStyle: const TextStyle(color: AppPalette.contrastMedium),
                    prefixIcon: const Icon(Icons.search, color: AppPalette.contrastMedium),
                    filled: true,
                    fillColor: AppPalette.backgroundCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppPalette.contrastLight),
                  onChanged: (query) {
                    context.read<ListenBloc>().add(ListenSearchTracksEvent(query));
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Genre filter chips
                BlocBuilder<ListenBloc, ListenState>(
                  builder: (context, state) {
                    if (state is ListenLoaded) {
                      final genres = ['All', ...state.availableGenres];
                      return SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          itemBuilder: (context, index) {
                            final genre = genres[index];
                            final isSelected = genre == 'All' 
                                ? state.currentGenreFilter == null
                                : state.currentGenreFilter == genre;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(genre),
                                selected: isSelected,
                                onSelected: (_) {
                                  context.read<ListenBloc>().add(
                                    ListenFilterByGenreEvent(genre),
                                  );
                                },
                                backgroundColor: AppPalette.backgroundCard,
                                selectedColor: AppPalette.musicPurple,
                                labelStyle: TextStyle(
                                  color: isSelected 
                                      ? AppPalette.contrastLight 
                                      : AppPalette.contrastMedium,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          
          // Track list
          Expanded(
            child: BlocBuilder<ListenBloc, ListenState>(
              builder: (context, state) {
                if (state is ListenLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppPalette.musicPurple,
                    ),
                  );
                }
                
                if (state is ListenError) {
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
                          'Error loading tracks',
                          style: const TextStyle(
                            color: AppPalette.contrastLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: AppPalette.contrastMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ListenBloc>().add(ListenInitializeEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.musicPurple,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is ListenLoaded) {
                  if (state.filteredTracks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off,
                            size: 64,
                            color: AppPalette.contrastMedium,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tracks found',
                            style: TextStyle(
                              color: AppPalette.contrastLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              color: AppPalette.contrastMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredTracks.length,
                    itemBuilder: (context, index) {
                      final track = state.filteredTracks[index];
                      final isCurrentTrack = state.currentTrack?.id == track.id;
                      final isLiked = state.isTrackLiked(track.id);
                      
                      return _TrackTile(
                        track: track,
                        isCurrentTrack: isCurrentTrack,
                        isPlaying: isCurrentTrack && state.isPlaying,
                        isLiked: isLiked,
                        onTap: () {
                          context.read<ListenBloc>().add(
                            ListenPlayTrackEvent(track),
                          );
                        },
                        onLike: () {
                          if (isLiked) {
                            context.read<ListenBloc>().add(
                              ListenUnlikeTrackEvent(track.id),
                            );
                          } else {
                            context.read<ListenBloc>().add(
                              ListenLikeTrackEvent(track.id),
                            );
                          }
                        },
                      );
                    },
                  );
                }
                
                return const Center(
                  child: Text(
                    'Welcome to MTM',
                    style: TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Mini player (if track is playing)
          BlocBuilder<ListenBloc, ListenState>(
            builder: (context, state) {
              if (state is ListenLoaded && state.hasCurrentTrack) {
                return _MiniPlayer(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final Track track;
  final bool isCurrentTrack;
  final bool isPlaying;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _TrackTile({
    required this.track,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentTrack 
            ? AppPalette.musicPurple.withOpacity(0.2)
            : AppPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTrack
            ? Border.all(color: AppPalette.musicPurple, width: 1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppPalette.musicPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppPalette.contrastLight,
          ),
        ),
        title: Text(
          track.title,
          style: TextStyle(
            color: AppPalette.contrastLight,
            fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.artist,
              style: const TextStyle(color: AppPalette.contrastMedium),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppPalette.musicBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    track.genre,
                    style: const TextStyle(
                      color: AppPalette.contrastLight,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  track.formattedDuration,
                  style: const TextStyle(
                    color: AppPalette.contrastMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: onLike,
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppPalette.musicPink : AppPalette.contrastMedium,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  final ListenLoaded state;

  const _MiniPlayer({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppPalette.musicGradient,
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                state.position.inMinutes.toString().padLeft(2, '0') + 
                ':' + (state.position.inSeconds % 60).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppPalette.contrastLight,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Slider(
                  value: state.progressPercentage,
                  onChanged: (value) {
                    if (state.duration != null) {
                      final position = Duration(
                        milliseconds: (value * state.duration!.inMilliseconds).round(),
                      );
                      context.read<ListenBloc>().add(ListenSeekEvent(position));
                    }
                  },
                  activeColor: AppPalette.contrastLight,
                  inactiveColor: AppPalette.contrastMedium,
                ),
              ),
              Text(
                state.duration?.inMinutes.toString().padLeft(2, '0') ?? '0' + 
                ':' + ((state.duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppPalette.contrastLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // Track info and controls
          Row(
            children: [
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentTrack?.title ?? '',
                      style: const TextStyle(
                        color: AppPalette.contrastLight,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      state.currentTrack?.artist ?? '',
                      style: const TextStyle(
                        color: AppPalette.contrastMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Controls
              Row(
                children: [
                  IconButton(
                    onPressed: state.canGoPrevious
                        ? () => context.read<ListenBloc>().add(ListenPreviousTrackEvent())
                        : null,
                    icon: const Icon(Icons.skip_previous),
                    color: AppPalette.contrastLight,
                  ),
                  IconButton(
                    onPressed: () {
                      if (state.isPlaying) {
                        context.read<ListenBloc>().add(ListenPauseEvent());
                      } else {
                        context.read<ListenBloc>().add(ListenResumeEvent());
                      }
                    },
                    icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                    color: AppPalette.contrastLight,
                    iconSize: 32,
                  ),
                  IconButton(
                    onPressed: state.canGoNext
                        ? () => context.read<ListenBloc>().add(ListenNextTrackEvent())
                        : null,
                    icon: const Icon(Icons.skip_next),
                    color: AppPalette.contrastLight,
                  ),
                ],
              ),
            ],
          ),
          
          // Reward status
          if (state.currentSessionData != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.isSessionEligibleForRewards
                    ? AppPalette.success.withOpacity(0.3)
                    : AppPalette.warning.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    state.isSessionEligibleForRewards 
                        ? Icons.monetization_on 
                        : Icons.access_time,
                    color: AppPalette.contrastLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.sessionStatusText,
                      style: const TextStyle(
                        color: AppPalette.contrastLight,
                        fontSize: 12,
                      ),
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