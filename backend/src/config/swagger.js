const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'LocalAI Backend API',
      version: '1.0.0',
      description: 'API documentation for the LocalAI application backend, featuring authentication, user management, and AI recommendations.',
      contact: {
        name: 'API Support',
        email: 'support@localai.com',
      },
    },
    servers: [
      {
        url: '/api/v1',
        description: 'V1 API Server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            status: { type: 'string', example: 'error' },
            errorCode: { 
              type: 'string', 
              description: 'Standardized error code',
              enum: ['INTERNAL_ERROR', 'UNAUTHORIZED', 'FORBIDDEN', 'NOT_FOUND', 'VALIDATION_ERROR', 'RATE_LIMIT_EXCEEDED'] 
            },
            message: { type: 'string' },
            stack: { type: 'object' },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            username: { type: 'string' },
            email: { type: 'string', format: 'email' },
            role: { type: 'string', enum: ['user', 'admin'] },
            isVerified: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
      },
      parameters: {
        RateLimitHeaders: {
          XRateLimitLimit: {
            in: 'header',
            description: 'The maximum number of requests allowed in the time window',
            schema: { type: 'integer' }
          },
          XRateLimitRemaining: {
            in: 'header',
            description: 'The number of requests remaining in the current window',
            schema: { type: 'integer' }
          }
        }
      }
    },

    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/routes/*.js', './src/controllers/*.js', './src/routes/swaggerAnnotations.js'], // Files containing annotations
};

const specs = swaggerJsdoc(options);
module.exports = specs;
