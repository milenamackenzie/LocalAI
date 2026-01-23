const recommendationRepository = require('../repositories/recommendationRepository');
const aiService = require('../services/aiService');
const preferenceRepository = require('../repositories/preferenceRepository');

class RecommendationService {
    
    async getRecommendations(userId, filters) {
        return await recommendationRepository.findWithFilters({ userId, ...filters });
    }

    async generate(userId, context, options = {}) {
        const mode = options.mode || 'hybrid'; // 'traditional' or 'hybrid'
        
        // 1. Gather User Context (Preferences, History)
        const preferences = await preferenceRepository.findByUserId(userId);
        
        // Convert DB rows to cleaner object
        const userProfile = {
            interests: preferences.map(p => p.category),
            preferences: preferences.reduce((acc, p) => {
                acc[p.category] = p.preference_value;
                return acc;
            }, {})
        };

        let recData;

        if (mode === 'traditional') {
            // Traditional Rule-based Recommendation
            const candidates = this._getTraditionalCandidates(userProfile.interests);
            const selected = candidates[Math.floor(Math.random() * candidates.length)];
            
            recData = {
                userId,
                itemType: 'traditional',
                itemTitle: selected.title,
                itemDescription: selected.description,
                score: 0.7,
                category: selected.category,
                context: context
            };
        } else {
            // 2. Call AI Service (Hybrid)
            const aiResult = await aiService.generateRecommendation(userProfile, context);

            // 3. Prepare Recommendation Data
            recData = {
                userId,
                itemType: 'ai_generated',
                itemTitle: aiResult.item_title,
                itemDescription: aiResult.item_description,
                score: aiResult.score || 0.5,
                category: aiResult.category || 'general',
                context: context
            };
        }

        return await recommendationRepository.create(recData);
    }

    _getTraditionalCandidates(interests) {
        const catalog = [
            { title: "Local Gym", description: "Stay fit at the nearby gym.", category: "Fitness" },
            { title: "Yoga Studio", description: "Relax and stretch in a group class.", category: "Fitness" },
            { title: "Tech Meetup", description: "Network with other developers.", category: "Technology" },
            { title: "Gourmet Kitchen", description: "Try some amazing local dishes.", category: "Food" },
            { title: "Art Gallery", description: "Explore contemporary art exhibitions.", category: "Culture" },
            { title: "Public Park", description: "A nice place for a walk.", category: "General" }
        ];

        if (!interests || interests.length === 0) {
            return catalog.filter(i => i.category === 'General');
        }

        const matches = catalog.filter(item => interests.includes(item.category));
        return matches.length > 0 ? matches : catalog.filter(i => i.category === 'General');
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
