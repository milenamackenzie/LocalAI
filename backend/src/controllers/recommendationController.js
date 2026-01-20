const recommendationRepository = require('../repositories/recommendationRepository');
const logger = require('../utils/logger');

exports.getRecommendations = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const recommendations = await recommendationRepository.findByUserId(userId);
    
    res.status(200).json({
      success: true,
      count: recommendations.length,
      data: recommendations
    });
  } catch (err) {
    next(err);
  }
};

exports.generateRecommendations = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { context } = req.body; // e.g. "Hiking", "Italian Food"

    // TODO: Connect to actual LocalAI Model here
    // For now, return a mock recommendation based on context
    
    logger.info(`Generating recommendation for user ${userId} with context: ${context}`);

    const mockRec = {
      userId,
      itemType: 'place',
      itemTitle: `Best Spot for ${context || 'General'}`,
      itemDescription: `This is a highly rated spot matching your interest in ${context}.`,
      score: 0.95
    };

    const savedRec = await recommendationRepository.create(mockRec);

    res.status(201).json({
      success: true,
      message: 'Recommendation generated',
      data: savedRec
    });
  } catch (err) {
    next(err);
  }
};
