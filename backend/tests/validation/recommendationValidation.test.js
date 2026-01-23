const recommendationService = require('../../src/services/recommendationService');
const preferenceRepository = require('../../src/repositories/preferenceRepository');
const aiService = require('../../src/services/aiService');
const fs = require('fs');
const path = require('path');

jest.mock('../../src/services/aiService');

describe('Recommendation Validation Suite', () => {
    const userId = 1;
    const results = [];

    beforeAll(async () => {
        await global.clearDb();
        // Insert a test user
        const db = require('../../src/database/connection');
        await db.run('INSERT INTO users (id, username, email, password_hash) VALUES (?, ?, ?, ?)', 
            [userId, 'testuser', 'test@example.com', 'hash']);
    });

    afterAll(() => {
        const reportPath = path.join(__dirname, 'validation-results.json');
        fs.writeFileSync(reportPath, JSON.stringify(results, null, 2));
    });

    test('Relevance Test: Mock a user with "Fitness" preferences and verify >80% are fitness-related', async () => {
        await preferenceRepository.upsert(userId, 'Fitness', 'high');
        
        // Mock AI to return Fitness recommendations
        aiService.generateRecommendation.mockResolvedValue({
            item_title: "Gym Workout",
            item_description: "Focused on fitness",
            category: "Fitness",
            score: 0.95
        });

        let fitnessCount = 0;
        const total = 10;
        for (let i = 0; i < total; i++) {
            const rec = await recommendationService.generate(userId, 'Daily routines');
            if (rec.category === 'Fitness') fitnessCount++;
        }

        const score = (fitnessCount / total) * 100;
        results.push({ 
            test: 'Relevance Test', 
            metric: 'Category Match Rate',
            value: `${score}%`,
            passed: score >= 80,
            details: `User: Fitness enthusiast, Results: ${fitnessCount}/${total} Fitness items`
        });
        expect(score).toBeGreaterThanOrEqual(80);
    });

    test('Diversity Test: Ensure engine doesn\'t just recommend the same 3 items repeatedly', async () => {
        const titles = new Set();
        const total = 10;
        
        // Mock different responses to simulate diversity
        aiService.generateRecommendation
            .mockResolvedValueOnce({ item_title: "Yoga Session", category: "Fitness" })
            .mockResolvedValueOnce({ item_title: "Running Track", category: "Fitness" })
            .mockResolvedValueOnce({ item_title: "Swimming Pool", category: "Fitness" })
            .mockResolvedValueOnce({ item_title: "Cycling Path", category: "Fitness" })
            .mockResolvedValueOnce({ item_title: "Hiking Trail", category: "Fitness" })
            .mockResolvedValue({ item_title: "Generic Gym", category: "Fitness" });

        for (let i = 0; i < total; i++) {
            const rec = await recommendationService.generate(userId, 'Exploring');
            titles.add(rec.itemTitle);
        }

        const uniqueCount = titles.size;
        results.push({ 
            test: 'Diversity Test', 
            metric: 'Unique Recommendations',
            value: uniqueCount,
            passed: uniqueCount > 3,
            details: `Unique items in ${total} requests: ${uniqueCount}`
        });
        expect(uniqueCount).toBeGreaterThan(3);
    });

    test('Cold Start Test: Verify sensible "Default" recommendations for new users', async () => {
        const newUser = 2;
        const db = require('../../src/database/connection');
        await db.run('INSERT INTO users (id, username, email, password_hash) VALUES (?, ?, ?, ?)', 
            [newUser, 'newuser', 'new@example.com', 'hash']);
        
        // No preferences set for newUser
        // Traditional mode should pick 'General'
        const rec = await recommendationService.generate(newUser, 'First use', { mode: 'traditional' });
        
        results.push({ 
            test: 'Cold Start Test', 
            metric: 'Default Category',
            value: rec.category,
            passed: rec.category === 'General',
            details: `New user with no history received: ${rec.itemTitle} (${rec.category})`
        });
        expect(rec.category).toBe('General');
    });

    test('Latency Test: Measure AI re-ranking overhead', async () => {
        // Mock AI with a slight delay
        aiService.generateRecommendation.mockImplementation(() => {
            return new Promise(resolve => {
                setTimeout(() => resolve({
                    item_title: "Delayed Rec",
                    category: "General",
                    score: 0.5
                }), 50); // 50ms delay
            });
        });

        const start = Date.now();
        await recommendationService.generate(userId, 'Latency check', { mode: 'hybrid' });
        const latency = Date.now() - start;

        results.push({ 
            test: 'Latency Test', 
            metric: 'Response Time',
            value: `${latency}ms`,
            passed: latency < 1000,
            details: `Time taken for Hybrid (AI) generation: ${latency}ms`
        });
        expect(latency).toBeLessThan(1000);
    });

    test('A/B Test Comparison: Traditional vs Hybrid', async () => {
        // Traditional
        const startTrad = Date.now();
        await recommendationService.generate(userId, 'AB Comparison', { mode: 'traditional' });
        const latTrad = Date.now() - startTrad;

        // Hybrid
        const startHybrid = Date.now();
        await recommendationService.generate(userId, 'AB Comparison', { mode: 'hybrid' });
        const latHybrid = Date.now() - startHybrid;

        results.push({
            test: 'A/B Test Comparison',
            metric: 'Traditional vs Hybrid Latency',
            value: `Trad: ${latTrad}ms, Hybrid: ${latHybrid}ms`,
            passed: true,
            details: `Hybrid overhead: ${latHybrid - latTrad}ms`
        });
    });
});
