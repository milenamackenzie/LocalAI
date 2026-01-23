import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String id;
  final String title;
  final String category;
  final double score;
  final String? imageUrl;
  final bool isBookmarked;
  final double? averageRating;
  final int? reviewCount;

  const Location({
    required this.id,
    required this.title,
    required this.category,
    required this.score,
    this.imageUrl,
    this.isBookmarked = false,
    this.averageRating,
    this.reviewCount,
  });

  Location copyWith({bool? isBookmarked}) {
    return Location(
      id: id,
      title: title,
      category: category,
      score: score,
      imageUrl: imageUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [id, title, category, score, imageUrl, isBookmarked, averageRating, reviewCount];

  Location copyWith({
    String? id,
    String? title,
    String? category,
    double? score,
    String? imageUrl,
    bool? isBookmarked,
    double? averageRating,
    int? reviewCount,
  }) {
    return Location(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      score: score ?? this.score,
      imageUrl: imageUrl ?? this.imageUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
