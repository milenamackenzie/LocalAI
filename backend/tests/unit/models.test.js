const User = require('../../src/models/User');
const Interaction = require('../../src/models/Interaction');

jest.mock('../../src/services/queueService');

describe('Unit Tests: Data Models', () => {
  describe('User Model', () => {
    test('should correctly instantiate from DB row', () => {
      const row = { id: 1, username: 'testuser', email: 'test@example.com', password_hash: 'hash' };
      const user = new User(row);
      expect(user.id).toBe(1);
    });
  });
});
