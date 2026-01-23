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
    test('should register a new user successfully and return verification token', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send(validUser);
      
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.verificationToken).toBeDefined();
      expect(res.body.data.token).toBeUndefined(); // No access token on register anymore
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
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
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
    let accessToken;

    beforeEach(async () => {
      // 1. Register
      await request(app).post('/api/v1/auth/register').send(validUser);
      // 2. Login to get token
      const loginRes = await request(app).post('/api/v1/auth/login').send({
          email: validUser.email,
          password: validUser.password
      });
      accessToken = loginRes.body.data.accessToken;
    });

    test('should return profile for authenticated user', async () => {
      const res = await request(app)
        .get('/api/v1/users/profile')
        .set('Authorization', `Bearer ${accessToken}`);
      
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
