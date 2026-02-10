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
  final List<Location>? previousBookmarks; // For undo
  const BookmarkError(this.message, {this.previousBookmarks});
  @override
  List<Object?> get props => [message, previousBookmarks];
}

// Events
abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();
  @override
  List<Object> get props => [];
}

class LoadBookmarksRequested extends BookmarkEvent {}
class SyncBookmarksRequested extends BookmarkEvent {}

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

    on<SyncBookmarksRequested>((event, emit) async {
      final result = await bookmarkRepository.syncWithBackend();
      await result.fold(
        (failure) async => null, // Silent fail for sync in background
        (_) async {
          add(LoadBookmarksRequested());
        },
      );
    });

    on<ToggleBookmarkRequested>((event, emit) async {
      final currentState = state;
      List<Location> previousBookmarks = [];
      if (currentState is BookmarksLoaded) {
        previousBookmarks = List.from(currentState.bookmarks);
      }

      final isCurrentlyBookmarked = previousBookmarks.any((b) => b.id == event.location.id);
      List<Location> updatedBookmarks = List.from(previousBookmarks);

      // Optimistic UI Update
      if (isCurrentlyBookmarked) {
        updatedBookmarks.removeWhere((b) => b.id == event.location.id);
      } else {
        updatedBookmarks.add(event.location.copyWith(isBookmarked: true));
      }
      emit(BookmarksLoaded(updatedBookmarks));

      // Background Call
      if (isCurrentlyBookmarked) {
        final result = await bookmarkRepository.removeBookmark(event.location.id);
        result.fold(
          (failure) {
            // Undo optimistic update on failure
            emit(BookmarkError(failure.message, previousBookmarks: previousBookmarks));
            emit(BookmarksLoaded(previousBookmarks));
          },
          (success) => null,
        );
      } else {
        final result = await bookmarkRepository.addBookmark(event.location);
        result.fold(
          (failure) {
            // Undo optimistic update on failure
            emit(BookmarkError(failure.message, previousBookmarks: previousBookmarks));
            emit(BookmarksLoaded(previousBookmarks));
          },
          (success) => null,
        );
      }
    });
  }
}
