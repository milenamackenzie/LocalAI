import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

import '../../domain/entities/user.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});
  @override
  List<Object?> get props => [message];
}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested(this.email, this.password);
}
class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  const RegisterRequested(this.username, this.email, this.password);
}
class UserLoggedOut extends AuthEvent {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (_) => emit(const Unauthenticated()),
        (user) => emit(Authenticated(user)),
      );
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.login(event.email, event.password);
      result.fold(
        (failure) => emit(Unauthenticated(message: failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.register(event.username, event.email, event.password);
      result.fold(
        (failure) => emit(Unauthenticated(message: failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<UserLoggedOut>((event, emit) async {
      await authRepository.logout();
      emit(const Unauthenticated());
    });
  }
}
