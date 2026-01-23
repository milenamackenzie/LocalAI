import 'package:equatable/equatable.dart';
import 'user.dart';

class Review extends Equatable {
  final String id;
  final String locationId;
  final String userId;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final User? user; // Optional for displaying user info

  const Review({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
  });

  @override
  List<Object?> get props => [id, locationId, userId, rating, comment, createdAt, user];

  Review copyWith({
    String? id,
    String? locationId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    User? user,
  }) {
    return Review(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      userId: json['userId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}