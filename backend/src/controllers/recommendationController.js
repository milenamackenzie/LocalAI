const recommendationService = require('../services/recommendationService');
const logger = require('../utils/logger');

exports.getRecommendations = async (req, res, next) => {
  try {
    const filters = {
        category: req.query.category,
        minScore: req.query.minScore ? parseFloat(req.query.minScore) : null,
        limit: req.query.limit ? parseInt(req.query.limit) : 20,
        page: req.query.page ? parseInt(req.query.page) : 1
    };
    filters.offset = (filters.page - 1) * filters.limit;

    const data = await recommendationService.getRecommendations(req.user.id, filters);
    
    res.status(200).json({
      success: true,
      count: data.length,
      data: data,
      meta: { page: filters.page, limit: filters.limit }
    });
  } catch (err) {
    next(err);
  }
};

exports.generateRecommendations = async (req, res, next) => {
  try {
    const { context } = req.body;
    const recommendation = await recommendationService.generate(req.user.id, context);

    res.status(201).json({
      success: true,
      message: 'Recommendation generated',
      data: recommendation
    });
  } catch (err) {
    next(err);
  }
};

exports.getRecommendationById = async (req, res, next) => {
    // Basic implementation using the list filter for now, or add specific repo method
    // For simplicity, we assume frontend has list or we add detailed fetch if needed
    res.status(501).json({ message: 'Not implemented yet' });
};

exports.updateFeedback = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { feedback } = req.body; // 'liked', 'disliked'
        
        await recommendationService.submitFeedback(id, req.user.id, feedback);
        res.status(200).json({ success: true, message: 'Feedback received' });
    } catch (err) {
        next(err);
    }
};

exports.deleteRecommendation = async (req, res, next) => {
    try {
        const { id } = req.params;
        await recommendationService.deleteRecommendation(id, req.user.id);
        res.status(200).json({ success: true, message: 'Recommendation removed' });
    } catch (err) {
        next(err);
    }
};

exports.getAnalytics = async (req, res, next) => {
    try {
        const data = await recommendationService.getAnalytics(req.user.id);
        res.status(200).json({ success: true, data });
    } catch (err) {
        next(err);
    }
};
