const recommendationRepository = require('../repositories/recommendationRepository');
const aiService = require('../services/aiService');
const preferenceRepository = require('../repositories/preferenceRepository');

class RecommendationService {
    
    async getRecommendations(userId, filters) {
        return await recommendationRepository.findWithFilters({ userId, ...filters });
    }

    async generate(userId, context) {
        // 1. Gather User Context (Preferences, History)
        const preferences = await preferenceRepository.findByUserId(userId);
        
        // Convert DB rows to cleaner object
        const userProfile = {
            interests: [], // Extract from preferences if structured
            preferences: preferences.reduce((acc, p) => {
                acc[p.category] = p.preference_value;
                return acc;
            }, {})
        };

        // 2. Call AI Service
        const aiResult = await aiService.generateRecommendation(userProfile, context);

        // 3. Save Recommendation
        const recData = {
            userId,
            itemType: 'ai_generated',
            itemTitle: aiResult.item_title,
            itemDescription: aiResult.item_description,
            score: aiResult.score || 0.5,
            category: aiResult.category || 'general',
            context: context
        };

        return await recommendationRepository.create(recData);
    }

    async submitFeedback(id, userId, feedback) {
        if (!['liked', 'disliked', 'none'].includes(feedback)) {
            throw new Error('Invalid feedback status');
        }
        await recommendationRepository.updateFeedback(id, userId, feedback);
        
        // TODO: Trigger learning loop (update user preferences vector)
        return { success: true };
    }

    async getAnalytics(userId) {
        return await recommendationRepository.getAnalytics(userId);
    }

    async deleteRecommendation(id, userId) {
        await recommendationRepository.archive(id, userId);
    }
}

module.exports = new RecommendationService();
