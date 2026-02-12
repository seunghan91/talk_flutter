import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/domain/repositories/feedback_repository.dart';

// ============ Events ============

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Submit feedback to the server
class FeedbackSubmitted extends FeedbackEvent {
  final String category;
  final String content;

  const FeedbackSubmitted({required this.category, required this.content});

  @override
  List<Object?> get props => [category, content];
}

/// Reset feedback state to initial
class FeedbackReset extends FeedbackEvent {
  const FeedbackReset();
}

// ============ State ============

enum FeedbackStatus { initial, submitting, success, error }

class FeedbackState extends Equatable {
  final FeedbackStatus status;
  final String? errorMessage;

  const FeedbackState({
    this.status = FeedbackStatus.initial,
    this.errorMessage,
  });

  bool get isSubmitting => status == FeedbackStatus.submitting;

  FeedbackState copyWith({FeedbackStatus? status, String? errorMessage}) {
    return FeedbackState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

// ============ BLoC ============

/// FeedbackBloc - manages feedback submission state
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository _feedbackRepository;

  FeedbackBloc({required FeedbackRepository feedbackRepository})
      : _feedbackRepository = feedbackRepository,
        super(const FeedbackState()) {
    on<FeedbackSubmitted>(_onSubmitted);
    on<FeedbackReset>(_onReset);
  }

  Future<void> _onSubmitted(
    FeedbackSubmitted event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(status: FeedbackStatus.submitting));

    try {
      await _feedbackRepository.submitFeedback(
        category: event.category,
        content: event.content,
      );
      emit(state.copyWith(status: FeedbackStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FeedbackStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onReset(FeedbackReset event, Emitter<FeedbackState> emit) {
    emit(const FeedbackState());
  }
}
