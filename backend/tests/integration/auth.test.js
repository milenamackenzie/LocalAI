const request = require('supertest');
const app = require('../../src/app');
const db = require('../../src/database/connection');

describe('Integration Tests: Auth Endpoints', () => {
  
  beforeEach(async () => {
    await global.clearDb();
  });

  const validUser = {
    username: 'integrationUser',
    email: 'integration@test.com',
    password: 'Password123!'
  };

  describe('POST /api/v1/auth/register', () => {
    test('should register a new user successfully', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send(validUser);
      
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.email).toBe(validUser.email);
      expect(res.body.data.token).toBeDefined();
    });

    test('should fail with weak password', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({ ...validUser, password: 'weak' });
      
      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });

    test('should fail if email already exists', async () => {
      // First register
      await request(app).post('/api/v1/auth/register').send(validUser);
      
      // Try again
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send(validUser);
      
      expect(res.status).toBe(409); // Conflict
    });
  });

  describe('POST /api/v1/auth/login', () => {
    beforeEach(async () => {
      await request(app).post('/api/v1/auth/register').send(validUser);
    });

    test('should login with valid credentials', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: validUser.email,
          password: validUser.password
        });
      
      expect(res.status).toBe(200);
      expect(res.body.data.token).toBeDefined();
    });

    test('should fail with wrong password', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: validUser.email,
          password: 'WrongPassword1!'
        });
      
      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/v1/users/profile', () => {
    let token;

    beforeEach(async () => {
      const reg = await request(app).post('/api/v1/auth/register').send(validUser);
      token = reg.body.data.token;
    });

    test('should return profile for authenticated user', async () => {
      const res = await request(app)
        .get('/api/v1/users/profile')
        .set('Authorization', `Bearer ${token}`);
      
      expect(res.status).toBe(200);
      expect(res.body.data.email).toBe(validUser.email);
      expect(res.body.data.password_hash).toBeUndefined();
    });

    test('should fail without token', async () => {
      const res = await request(app).get('/api/v1/users/profile');
      expect(res.status).toBe(401);
    });
  });
});
