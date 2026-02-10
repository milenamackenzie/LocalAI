const Queue = require('bull');
const logger = require('../utils/logger');
const aiService = require('./aiService');

class QueueService {
    constructor() {
        if (process.env.NODE_ENV === 'test') {
            this.isTestMode = true;
            return;
        }

        this.recommendationQueue = new Queue('ai-recommendations', {
            redis: {
                host: process.env.REDIS_HOST || '127.0.0.1',
                port: process.env.REDIS_PORT || 6379
            }
        });

        this.recommendationQueue.process(async (job) => {
            const { userProfile, context } = job.data;
            logger.info(`Processing AI recommendation job ${job.id}`);
            return await aiService.generateRecommendation(userProfile, context);
        });

        this.recommendationQueue.on('failed', (job, err) => {
            logger.error(`Job ${job.id} failed: ${err.message}`);
        });

        this.recommendationQueue.on('completed', (job, _result) => {
            logger.info(`Job ${job.id} completed successfully`);
        });
    }

    async addRecommendationJob(userProfile, context) {
        if (this.isTestMode) {
            // Bypass queue in test mode for faster integration tests
            const result = await aiService.generateRecommendation(userProfile, context);
            return {
                finished: () => Promise.resolve(result),
                id: 'mock-test-id'
            };
        }

        const job = await this.recommendationQueue.add({ userProfile, context }, {
            attempts: 3,
            backoff: 5000
        });
        return job;
    }

    async getJobResult(jobId) {
        const job = await this.recommendationQueue.getJob(jobId);
        if (!job) return null;
        
        const state = await job.getState();
        if (state === 'completed') {
            return job.returnvalue;
        } else if (state === 'failed') {
            throw new Error(job.failedReason);
        }
        return null;
    }

    async close() {
        if (this.isTestMode) return;
        await this.recommendationQueue.close();
    }
}

module.exports = new QueueService();
