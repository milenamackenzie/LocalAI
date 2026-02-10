const request = require('supertest');
const app = require('../../src/app');
const jwt = require('jsonwebtoken');

describe('Security: JWT Validation', () => {
    const secret = process.env.JWT_SECRET || 'fallback_secret';
    let validToken;

    beforeAll(async () => {
        const db = require('../../src/database/connection');
        await db.run('INSERT OR REPLACE INTO users (id, username, email, password_hash) VALUES (?, ?, ?, ?)', 
            [1, 'testuser', 'test@example.com', 'hash']);
        validToken = jwt.sign({ id: 1, username: 'testuser' }, secret, { expiresIn: '1h' });
    });

    test('Should reject token with invalid signature', async () => {
        const invalidToken = jwt.sign({ id: 1 }, 'wrong_secret');
        const response = await request(app)
            .get('/api/v1/users/profile')
            .set('Authorization', `Bearer ${invalidToken}`);
        
        expect(response.status).toBe(401);
    });

    test('Should reject expired token', async () => {
        const expiredToken = jwt.sign({ id: 1 }, secret, { expiresIn: '-1s' });
        const response = await request(app)
            .get('/api/v1/users/profile')
            .set('Authorization', `Bearer ${expiredToken}`);
        
        expect(response.status).toBe(401);
    });

    test('Should reject tampered payload', async () => {
        const parts = validToken.split('.');
        const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
        payload.role = 'admin'; 
        const tamperedPayload = Buffer.from(JSON.stringify(payload)).toString('base64');
        const tamperedToken = `${parts[0]}.${tamperedPayload}.${parts[2]}`;

        const response = await request(app)
            .get('/api/v1/users/profile')
            .set('Authorization', `Bearer ${tamperedToken}`);
        
        expect(response.status).toBe(401);
    });

    test('Should accept valid token', async () => {
        const response = await request(app)
            .get('/api/v1/users/profile')
            .set('Authorization', `Bearer ${validToken}`);
        
        expect(response.status).toBe(200);
    });
});
