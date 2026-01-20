const request = require('supertest');
const app = require('../../src/app');

describe('Integration Tests: Recommendation System', () => {
  let token;
  let recId;

  beforeAll(async () => {
    await global.clearDb();
    // Register & Login
    const user = { username: 'recUser', email: 'rec@test.com', password: 'Password123!' };
    await request(app).post('/api/v1/auth/register').send(user);
    const loginRes = await request(app).post('/api/v1/auth/login').send(user);
    token = loginRes.body.data.accessToken;
  });

  describe('POST /generate', () => {
    test('should generate a recommendation', async () => {
      const res = await request(app)
        .post('/api/v1/recommendations/generate')
        .set('Authorization', `Bearer ${token}`)
        .send({ context: 'Testing AI' });
      
      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty('itemTitle');
      expect(res.body.data).toHaveProperty('category');
      recId = res.body.data.id;
    });
  });

  describe('PUT /:id/feedback', () => {
    test('should submit feedback', async () => {
      const res = await request(app)
        .put(`/api/v1/recommendations/${recId}/feedback`)
        .set('Authorization', `Bearer ${token}`)
        .send({ feedback: 'liked' });
      
      expect(res.status).toBe(200);
    });

    test('should validate feedback', async () => {
      const res = await request(app)
        .put(`/api/v1/recommendations/${recId}/feedback`)
        .set('Authorization', `Bearer ${token}`)
        .send({ feedback: 'bad_value' });
      
      expect(res.status).toBe(400);
    });
  });

  describe('GET /analytics', () => {
    test('should return stats', async () => {
      const res = await request(app)
        .get('/api/v1/recommendations/analytics')
        .set('Authorization', `Bearer ${token}`);
      
      expect(res.status).toBe(200);
      expect(res.body.data.stats).toHaveProperty('likes');
      expect(res.body.data.stats.likes).toBe(1); // From previous test
    });
  });

  describe('DELETE /:id', () => {
    test('should archive recommendation', async () => {
      const res = await request(app)
        .delete(`/api/v1/recommendations/${recId}`)
        .set('Authorization', `Bearer ${token}`);
      
      expect(res.status).toBe(200);
    });

    test('should not list archived items', async () => {
      const res = await request(app)
        .get('/api/v1/recommendations')
        .set('Authorization', `Bearer ${token}`);
      
      expect(res.body.data.find(r => r.id === recId)).toBeUndefined();
    });
  });
});
