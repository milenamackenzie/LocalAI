import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  const ThemeChanged(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

// State
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ThemeChanged>((event, emit) {
      emit(ThemeState(event.themeMode));
    });
  }
}
