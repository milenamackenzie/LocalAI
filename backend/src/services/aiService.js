const axios = require('axios');
const logger = require('../utils/logger');

class AIService {
    constructor() {
        this.baseUrl = process.env.LM_STUDIO_URL || 'http://localhost:1234/v1';
        this.model = process.env.AI_MODEL || 'local-model';
        
        // Circuit Breaker State
        this.failureCount = 0;
        this.lastFailureTime = null;
        this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
        this.FAILURE_THRESHOLD = 5;
        this.RECOVERY_TIMEOUT = 30000; // 30 seconds
    }

    async generateRecommendation(userProfile, context) {
        this._checkCircuit();

        if (this.state === 'OPEN') {
            logger.warn('Circuit Breaker is OPEN. Returning fallback response.');
            return this._mockResponse(context);
        }

        const prompt = this._buildPrompt(userProfile, context);
        
        try {
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

            this._onSuccess();
            const content = response.data.choices[0].message.content;
            return this._parseResponse(content);

        } catch (error) {
            this._onFailure(error);
            logger.error(`AI Generation failed: ${error.message}`);
            return this._mockResponse(context);
        }
    }

    _checkCircuit() {
        if (this.state === 'OPEN' && Date.now() - this.lastFailureTime > this.RECOVERY_TIMEOUT) {
            this.state = 'HALF_OPEN';
            logger.info('Circuit Breaker is HALF_OPEN. Attempting recovery.');
        }
    }

    _onSuccess() {
        this.failureCount = 0;
        this.state = 'CLOSED';
        this.lastFailureTime = null;
    }

    _onFailure(error) {
        this.failureCount++;
        this.lastFailureTime = Date.now();
        if (this.failureCount >= this.FAILURE_THRESHOLD) {
            this.state = 'OPEN';
            logger.error(`Circuit Breaker transition to OPEN due to ${this.failureCount} failures.`);
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
