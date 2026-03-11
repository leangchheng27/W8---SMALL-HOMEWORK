import 'package:flutter/material.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../states/player_state.dart';
import '../../../../model/songs/song.dart';

enum AsyncStatus { loading, success, error }

class AsyncValue<T> {
  final T? value;
  final String? error;
  final AsyncStatus status;

  AsyncValue({this.value, this.error, this.status = AsyncStatus.loading});
}

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final PlayerState playerState;
  AsyncValue<List<Song>> _songs = AsyncValue(status: AsyncStatus.loading);

  LibraryViewModel({required this.songRepository, required this.playerState}) {
    playerState.addListener(notifyListeners);

    // init
    _init();
  }

  List<Song> get songs => _songs.value ?? [];
  bool get isLoading => _songs.status == AsyncStatus.loading;
  String? get error => _songs.error;

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  void _init() async {
    // 1 - Fetch songs
    _songs = AsyncValue(status: AsyncStatus.loading);

    // 2 - notify listeners
    notifyListeners();

    try {
      final result = await songRepository.fetchSongs();
      _songs = AsyncValue(value: result, status: AsyncStatus.success);
    } catch (e) {
      _songs = AsyncValue(error: e.toString(), status: AsyncStatus.error);
    }
    notifyListeners();
  }

  bool isSongPlaying(Song song) => playerState.currentSong == song;

  void start(Song song) => playerState.start(song);
  void stop(Song song) => playerState.stop();
}
