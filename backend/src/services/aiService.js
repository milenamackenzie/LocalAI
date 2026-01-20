const axios = require('axios');
const logger = require('../utils/logger');

class AIService {
    constructor() {
        // Default to local LM Studio endpoint
        this.baseUrl = process.env.LM_STUDIO_URL || 'http://localhost:1234/v1';
        this.model = process.env.AI_MODEL || 'local-model'; // Can be overridden
    }

    /**
     * Generate a recommendation based on user profile and context
     * @param {Object} userProfile - User interests, past interactions
     * @param {String} context - Specific request context (e.g., "weekend activity")
     * @returns {Promise<Object>} - Structured recommendation
     */
    async generateRecommendation(userProfile, context) {
        // Construct prompt
        const prompt = this._buildPrompt(userProfile, context);
        
        try {
            // Check if we are in test/dev mode without real AI
            if (process.env.NODE_ENV === 'test' || process.env.MOCK_AI === 'true') {
                return this._mockResponse(context);
            }

            const response = await axios.post(`${this.baseUrl}/chat/completions`, {
                model: this.model,
                messages: [
                    { role: "system", content: "You are a helpful local assistant. Recommend specific activities or places. Return ONLY JSON with fields: item_title, item_description, category, score (0-1)." },
                    { role: "user", content: prompt }
                ],
                temperature: 0.7,
                max_tokens: 500
            });

            const content = response.data.choices[0].message.content;
            return this._parseResponse(content);

        } catch (error) {
            logger.error(`AI Generation failed: ${error.message}`);
            // Fallback
            return this._mockResponse(context);
        }
    }

    _buildPrompt(profile, context) {
        return `
        User Interests: ${JSON.stringify(profile.interests || [])}
        Recent Likes: ${JSON.stringify(profile.recentLikes || [])}
        Context: ${context}
        
        Suggest one recommendation.
        `;
    }

    _parseResponse(content) {
        try {
            // Attempt to parse JSON from AI response
            // AI might wrap in markdown ```json ... ```
            const jsonMatch = content.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                return JSON.parse(jsonMatch[0]);
            }
            throw new Error('No JSON found');
        } catch (e) {
            logger.warn('Failed to parse AI response, returning text object');
            return {
                item_title: "AI Suggestion",
                item_description: content,
                category: "general",
                score: 0.5
            };
        }
    }

    _mockResponse(context) {
        return {
            item_title: `Mock Recommendation for ${context}`,
            item_description: "This is a simulated AI response for development purposes.",
            category: "test",
            score: 0.95
        };
    }
}

module.exports = new AIService();
