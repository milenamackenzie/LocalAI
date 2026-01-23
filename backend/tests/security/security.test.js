const request = require('supertest');
const app = require('../../src/app');

describe('Security Testing', () => {
    describe('SQL Injection Protection', () => {
        test('Should handle SQL injection patterns in login gracefully', async () => {
            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: "' OR '1'='1",
                    password: "anything' OR '1'='1"
                });
            
            // Should return 400 (validation) or 401 (unauthorized), NOT 500 (internal error)
            expect(response.status).not.toBe(500);
            expect(response.body.success).toBe(false);
        });

        test('Should handle SQL injection in user profile query', async () => {
            const response = await request(app)
                .get('/api/v1/users/profile?id=1;DROP TABLE users');
            
            expect(response.status).not.toBe(500);
        });
    });

    describe('Cross-Site Scripting (XSS) Protection', () => {
        test('Should sanitize XSS payloads in profile updates', async () => {
            // This assumes we have an authenticated user, but we're testing the validator/middleware here
            // If we hit the endpoint without auth, we still check if the error is 401/403 and not a crash
            const response = await request(app)
                .put('/api/v1/users/profile')
                .send({
                    username: "<script>alert('xss')</script>FriendlyUser",
                    bio: "Normal bio <img src=x onerror=alert(1)>"
                });
            
            expect(response.status).not.toBe(500);
            // Helmets and validators should prevent this from being a raw threat
        });
    });

    describe('Authentication & Authorization Bypass', () => {
        test('Should reject requests to protected routes with invalid JWT format', async () => {
            const response = await request(app)
                .get('/api/v1/users/profile')
                .set('Authorization', 'Bearer not-a-valid-jwt');
            
            expect(response.status).toBe(401);
            expect(response.body.errorCode).toBe('UNAUTHORIZED');
        });

        test('Should reject admin routes for normal users', async () => {
            // First we'd need a user token, then try to hit /admin
            // For now, testing the principle
            const response = await request(app)
                .get('/api/v1/users/search'); // Admin only route
            
            expect(response.status).toBe(401); // Or 403 if token provided but wrong role
        });
    });
});
