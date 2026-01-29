import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';

// ==================== Events ====================

abstract class BroadcastEvent extends Equatable {
  const BroadcastEvent();

  @override
  List<Object?> get props => [];
}

class BroadcastListRequested extends BroadcastEvent {
  final bool refresh;

  const BroadcastListRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class BroadcastCreateRequested extends BroadcastEvent {
  final String audioPath;
  final int duration;
  final int recipientCount;

  const BroadcastCreateRequested({
    required this.audioPath,
    required this.duration,
    this.recipientCount = 5,
  });

  @override
  List<Object?> get props => [audioPath, duration, recipientCount];
}

class BroadcastReplyRequested extends BroadcastEvent {
  final int broadcastId;
  final String audioPath;
  final int duration;

  const BroadcastReplyRequested({
    required this.broadcastId,
    required this.audioPath,
    required this.duration,
  });

  @override
  List<Object?> get props => [broadcastId, audioPath, duration];
}

class BroadcastMarkListened extends BroadcastEvent {
  final int broadcastId;

  const BroadcastMarkListened(this.broadcastId);

  @override
  List<Object?> get props => [broadcastId];
}

// ==================== State ====================

enum BroadcastStatus { initial, loading, loaded, creating, error }

class BroadcastState extends Equatable {
  final BroadcastStatus status;
  final List<Broadcast> broadcasts;
  final String? errorMessage;
  final bool hasReachedMax;
  final int page;

  const BroadcastState({
    this.status = BroadcastStatus.initial,
    this.broadcasts = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.page = 1,
  });

  bool get isLoading => status == BroadcastStatus.loading;
  bool get isCreating => status == BroadcastStatus.creating;

  BroadcastState copyWith({
    BroadcastStatus? status,
    List<Broadcast>? broadcasts,
    String? errorMessage,
    bool? hasReachedMax,
    int? page,
  }) {
    return BroadcastState(
      status: status ?? this.status,
      broadcasts: broadcasts ?? this.broadcasts,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [status, broadcasts, errorMessage, hasReachedMax, page];
}

// ==================== BLoC ====================

class BroadcastBloc extends Bloc<BroadcastEvent, BroadcastState> {
  final BroadcastRepository _broadcastRepository;

  BroadcastBloc({
    required BroadcastRepository broadcastRepository,
  })  : _broadcastRepository = broadcastRepository,
        super(const BroadcastState()) {
    on<BroadcastListRequested>(_onListRequested);
    on<BroadcastCreateRequested>(_onCreateRequested);
    on<BroadcastReplyRequested>(_onReplyRequested);
    on<BroadcastMarkListened>(_onMarkListened);
  }

  Future<void> _onListRequested(
    BroadcastListRequested event,
    Emitter<BroadcastState> emit,
  ) async {
    if (state.hasReachedMax && !event.refresh) return;

    try {
      final page = event.refresh ? 1 : state.page;
      emit(state.copyWith(status: BroadcastStatus.loading));

      final broadcasts = await _broadcastRepository.getBroadcasts(page: page);

      emit(state.copyWith(
        status: BroadcastStatus.loaded,
        broadcasts: event.refresh ? broadcasts : [...state.broadcasts, ...broadcasts],
        hasReachedMax: broadcasts.isEmpty,
        page: page + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BroadcastStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateRequested(
    BroadcastCreateRequested event,
    Emitter<BroadcastState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BroadcastStatus.creating));

      await _broadcastRepository.createBroadcast(
        audioPath: event.audioPath,
        duration: event.duration,
        recipientCount: event.recipientCount,
      );

      emit(state.copyWith(status: BroadcastStatus.loaded));

      // Refresh list after creating
      add(const BroadcastListRequested(refresh: true));
    } catch (e) {
      emit(state.copyWith(
        status: BroadcastStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onReplyRequested(
    BroadcastReplyRequested event,
    Emitter<BroadcastState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BroadcastStatus.creating));

      await _broadcastRepository.replyToBroadcast(
        broadcastId: event.broadcastId,
        audioPath: event.audioPath,
        duration: event.duration,
      );

      emit(state.copyWith(status: BroadcastStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: BroadcastStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMarkListened(
    BroadcastMarkListened event,
    Emitter<BroadcastState> emit,
  ) async {
    try {
      // Mark as listened locally
      final updatedBroadcasts = state.broadcasts.map((b) {
        if (b.id == event.broadcastId) {
          return b.copyWith(isListened: true);
        }
        return b;
      }).toList();

      emit(state.copyWith(broadcasts: updatedBroadcasts));

      // Sync with server
      await _broadcastRepository.markAsListened(event.broadcastId);
    } catch (e) {
      // Silent failure for marking as listened
    }
  }
}
