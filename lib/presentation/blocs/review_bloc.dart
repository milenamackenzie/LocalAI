import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

// States
abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;

  const ReviewsLoaded(this.reviews, this.averageRating, this.totalReviews);

  @override
  List<Object?> get props => [reviews, averageRating, totalReviews];
}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmitted extends ReviewState {
  final Review review;
  const ReviewSubmitted(this.review);
  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

// Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object> get props => [];
}

class LoadReviewsRequested extends ReviewEvent {
  final String locationId;
  const LoadReviewsRequested(this.locationId);
  @override
  List<Object> get props => [locationId];
}

class SubmitReviewRequested extends ReviewEvent {
  final Review review;
  const SubmitReviewRequested(this.review);
  @override
  List<Object> get props => [review];
}

class CheckUserReviewStatus extends ReviewEvent {
  final String locationId;
  final String userId;
  const CheckUserReviewStatus(this.locationId, this.userId);
  @override
  List<Object> get props => [locationId, userId];
}

// Bloc
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository reviewRepository;

  ReviewBloc({required this.reviewRepository}) : super(ReviewInitial()) {
    on<LoadReviewsRequested>((event, emit) async {
      emit(ReviewLoading());
      final result = await reviewRepository.getReviews(event.locationId);
      result.fold(
        (failure) => emit(ReviewError(failure.message)),
        (reviews) {
          final averageRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
          emit(ReviewsLoaded(reviews, averageRating, reviews.length));
        },
      );
    });

    on<SubmitReviewRequested>((event, emit) async {
      emit(ReviewSubmitting());

      // Check for duplicate review
      final hasReviewed = await reviewRepository.hasUserReviewed(event.review.locationId, event.review.userId);
      if (hasReviewed.isRight() && hasReviewed.getOrElse(() => false)) {
        emit(ReviewError('You have already reviewed this location'));
        return;
      }

      final result = await reviewRepository.submitReview(event.review);
      result.fold(
        (failure) => emit(ReviewError(failure.message)),
        (submittedReview) {
          emit(ReviewSubmitted(submittedReview));
          // Reload reviews to include the new one
          add(LoadReviewsRequested(event.review.locationId));
        },
      );
    });

    on<CheckUserReviewStatus>((event, emit) async {
      final result = await reviewRepository.hasUserReviewed(event.locationId, event.userId);
      // This could emit a state with review status if needed
      // For now, just check silently
    });
  }
}