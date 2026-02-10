const reviewRepository = require('../repositories/reviewRepository');
const logger = require('../utils/logger');

exports.getReviews = async (req, res, next) => {
  try {
    const { locationId } = req.params;
    const userId = req.query.userId;

    if (userId) {
      const userReview = await reviewRepository.findByUserAndLocation(userId, locationId);
      return res.status(200).json({
        success: true,
        reviews: userReview ? [userReview] : []
      });
    }

    const reviews = await reviewRepository.findByLocationId(locationId);
    const stats = await reviewRepository.getAverageRating(locationId);

    res.status(200).json({
      success: true,
      reviews: reviews.map(r => ({
        id: r.id.toString(),
        locationId: r.location_id.toString(),
        userId: r.user_id.toString(),
        rating: r.rating,
        comment: r.comment,
        createdAt: r.created_at,
        user: {
          id: r.user_id.toString(),
          username: r.username,
          avatarUrl: r.avatar_url
        }
      })),
      stats
    });
  } catch (err) {
    next(err);
  }
};

exports.submitReview = async (req, res, next) => {
  try {
    const { locationId, rating, comment } = req.body;
    const userId = req.user.id;

    // Check for existing review
    const existing = await reviewRepository.findByUserAndLocation(userId, locationId);
    if (existing) {
      return res.status(409).json({ success: false, message: 'You have already reviewed this location' });
    }

    const review = await reviewRepository.create({
      userId,
      locationId,
      rating,
      comment
    });

    logger.info(`Review submitted by user ${userId} for location ${locationId}`);

    res.status(201).json({
      success: true,
      message: 'Review submitted',
      review: {
        ...review,
        id: review.id.toString(),
        locationId: review.locationId.toString(),
        userId: review.userId.toString(),
        user: {
          id: userId.toString(),
          username: req.user.username, // Assuming req.user from authMiddleware has username
          avatarUrl: req.user.avatarUrl
        }
      }
    });
  } catch (err) {
    next(err);
  }
};
