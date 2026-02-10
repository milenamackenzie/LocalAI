import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/preference_repository.dart';
import '../../domain/entities/location.dart';

// States
abstract class UserHubState extends Equatable {
  const UserHubState();
  @override
  List<Object?> get props => [];
}

class UserHubInitial extends UserHubState {}
class UserHubLoading extends UserHubState {}
class UserHubLoaded extends UserHubState {
  final List<Location> recommendations;
  const UserHubLoaded(this.recommendations);
  @override
  List<Object?> get props => [recommendations];
}
class UserHubDetailLoaded extends UserHubState {
  final Location location;
  const UserHubDetailLoaded(this.location);
  @override
  List<Object?> get props => [location];
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

class LoadRecommendationDetailRequested extends UserHubEvent {
  final String id;
  const LoadRecommendationDetailRequested(this.id);
}

// Bloc
class UserHubBloc extends Bloc<UserHubEvent, UserHubState> {
  final PreferenceRepository preferenceRepository;

  UserHubBloc({required this.preferenceRepository}) : super(UserHubInitial()) {
    on<SyncPreferencesRequested>((event, emit) async {
      emit(UserHubLoading());
      final result = await preferenceRepository.syncPreferences(event.userId, event.categories);
      
      await result.fold(
        (failure) async => emit(UserHubError(failure.message)),
        (success) async {
          await preferenceRepository.generateSeedRecommendations();
          add(LoadRecommendationsRequested(event.userId));
        },
      );
    });

    on<LoadRecommendationsRequested>((event, emit) async {
      emit(UserHubLoading());
      final result = await preferenceRepository.getRecommendations();
      result.fold(
        (failure) => emit(UserHubError(failure.message)),
        (recommendations) => emit(UserHubLoaded(recommendations)),
      );
    });

    on<LoadRecommendationDetailRequested>((event, emit) async {
      emit(UserHubLoading());
      final result = await preferenceRepository.getRecommendationById(event.id);
      result.fold(
        (failure) => emit(UserHubError(failure.message)),
        (location) => emit(UserHubDetailLoaded(location)),
      );
    });
  }
}
