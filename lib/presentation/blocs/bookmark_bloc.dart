import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/bookmark_repository.dart';

// States
abstract class BookmarkState extends Equatable {
  const BookmarkState();
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}
class BookmarkLoading extends BookmarkState {}
class BookmarksLoaded extends BookmarkState {
  final List<Location> bookmarks;
  const BookmarksLoaded(this.bookmarks);
  @override
  List<Object?> get props => [bookmarks];
}
class BookmarkError extends BookmarkState {
  final String message;
  const BookmarkError(this.message);
  @override
  List<Object?> get props => [message];
}

// Events
abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();
  @override
  List<Object> get props => [];
}

class LoadBookmarksRequested extends BookmarkEvent {}

class ToggleBookmarkRequested extends BookmarkEvent {
  final Location location;
  const ToggleBookmarkRequested(this.location);
  @override
  List<Object> get props => [location];
}

// Bloc
class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkRepository bookmarkRepository;

  BookmarkBloc({required this.bookmarkRepository}) : super(BookmarkInitial()) {
    on<LoadBookmarksRequested>((event, emit) async {
      emit(BookmarkLoading());
      final result = await bookmarkRepository.getBookmarks();
      result.fold(
        (failure) => emit(BookmarkError(failure.message)),
        (bookmarks) => emit(BookmarksLoaded(bookmarks)),
      );
    });

    on<ToggleBookmarkRequested>((event, emit) async {
      final currentState = state;
      List<Location> currentBookmarks = [];
      if (currentState is BookmarksLoaded) {
        currentBookmarks = List.from(currentState.bookmarks);
      }

      final isCurrentlyBookmarked = currentBookmarks.any((b) => b.id == event.location.id);

      // Optimistic UI Update
      if (isCurrentlyBookmarked) {
        currentBookmarks.removeWhere((b) => b.id == event.location.id);
      } else {
        currentBookmarks.add(event.location.copyWith(isBookmarked: true));
      }
      emit(BookmarksLoaded(currentBookmarks));

      // Background Call
      if (isCurrentlyBookmarked) {
        final result = await bookmarkRepository.removeBookmark(event.location.id);
        result.fold(
          (failure) {
            // Undo optimistic update on failure
            add(LoadBookmarksRequested());
          },
          (success) => null,
        );
      } else {
        final result = await bookmarkRepository.addBookmark(event.location);
        result.fold(
          (failure) {
            // Undo optimistic update on failure
            add(LoadBookmarksRequested());
          },
          (success) => null,
        );
      }
    });
  }
}
