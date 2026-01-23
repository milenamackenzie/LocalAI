import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/preference_repository.dart';

// States
abstract class UserHubState extends Equatable {
  const UserHubState();
  @override
  List<Object?> get props => [];
}

class UserHubInitial extends UserHubState {}
class UserHubLoading extends UserHubState {}
class UserHubLoaded extends UserHubState {
  final List<dynamic> recommendations;
  const UserHubLoaded(this.recommendations);
  @override
  List<Object?> get props => [recommendations];
}
class UserHubError extends UserHubState {
  final String message;
  const UserHubError(this.message);
  @override
  List<Object?> get props => [message];
}

// Events
abstract class UserHubEvent extends Equatable {
  const UserHubEvent();
  @override
  List<Object> get props => [];
}

class SyncPreferencesRequested extends UserHubEvent {
  final String userId;
  final List<String> categories;
  const SyncPreferencesRequested(this.userId, this.categories);
}

class LoadRecommendationsRequested extends UserHubEvent {
  final String userId;
  const LoadRecommendationsRequested(this.userId);
}

// Bloc
class UserHubBloc extends Bloc<UserHubEvent, UserHubState> {
  final PreferenceRepository preferenceRepository;

  UserHubBloc({required this.preferenceRepository}) : super(UserHubInitial()) {
    on<SyncPreferencesRequested>((event, emit) async {
      emit(UserHubLoading());
      final result = await preferenceRepository.syncPreferences(event.userId, event.categories);
      result.fold(
        (failure) => emit(UserHubError(failure.message)),
        (success) {
          add(LoadRecommendationsRequested(event.userId));
        },
      );
    });

    on<LoadRecommendationsRequested>((event, emit) async {
      // Simulate fetching recommendations
      await Future.delayed(const Duration(seconds: 1));
      emit(const UserHubLoaded([]));
    });
  }
}
