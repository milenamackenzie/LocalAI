const request = require('supertest');
const app = require('../../src/app');

describe('Integration Tests: Feature Endpoints', () => {
  let token;
  const user = {
    username: 'featureUser',
    email: 'feature@test.com',
    password: 'Password123!'
  };

  beforeAll(async () => {
    await global.clearDb();
    // 1. Register
    await request(app).post('/api/v1/auth/register').send(user);
    // 2. Login to get token
    const res = await request(app).post('/api/v1/auth/login').send({
        email: user.email,
        password: user.password
    });
    if (!res.body.data) {
        console.error('Login failed in features test setup:', JSON.stringify(res.body, null, 2));
    }
    token = res.body.data.accessToken;
  });

  describe('Interactions API', () => {
    test('should log a valid interaction', async () => {
      const res = await request(app)
        .post('/api/v1/interactions')
        .set('Authorization', `Bearer ${token}`)
        .send({
          interactionType: 'view',
          itemId: 'place_123',
          itemType: 'place',
          data: { duration: 50 }
        });
      
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
    });

    test('should reject invalid interaction type', async () => {
      const res = await request(app)
        .post('/api/v1/interactions')
        .set('Authorization', `Bearer ${token}`)
        .send({
          interactionType: 'hacking',
          itemId: 'place_123',
          itemType: 'place'
        });
      
      expect(res.status).toBe(400);
    });
  });

  describe('Recommendations API', () => {
    test('should generate recommendation', async () => {
      const res = await request(app)
        .post('/api/v1/recommendations/generate')
        .set('Authorization', `Bearer ${token}`)
        .send({ context: 'Coffee' });
      
      expect(res.status).toBe(201);
      expect(res.body.data.itemTitle).toContain('Coffee');
    });

    test('should fetch recommendations list', async () => {
      const res = await request(app)
        .get('/api/v1/recommendations')
        .set('Authorization', `Bearer ${token}`);
      
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe('Health Check', () => {
    test('should return UP status', async () => {
      const res = await request(app).get('/api/v1/health');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('UP');
    });
  });
});
