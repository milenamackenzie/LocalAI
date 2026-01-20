const User = require('../../src/models/User');
const Interaction = require('../../src/models/Interaction');

describe('Unit Tests: Data Models', () => {
  
  describe('User Model', () => {
    test('should correctly instantiate from DB row', () => {
      const row = {
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        password_hash: 'hashed_secret',
        role: 'admin',
        created_at: '2023-01-01',
        updated_at: '2023-01-02'
      };
      
      const user = new User(row);
      expect(user.id).toBe(1);
      expect(user.username).toBe('testuser');
      expect(user.passwordHash).toBe('hashed_secret');
    });

    test('toJSON should remove passwordHash', () => {
      const user = new User({
        id: 1,
        username: 'test',
        password_hash: 'secret'
      });
      
      const json = user.toJSON();
      expect(json.passwordHash).toBeUndefined();
      expect(json.password_hash).toBeUndefined();
      expect(json.username).toBe('test');
    });
  });

  describe('Interaction Model', () => {
    test('isValid should return true for valid interaction', () => {
      const interaction = new Interaction({
        user_id: 1,
        interaction_type: 'click',
        item_id: '123',
        item_type: 'place'
      });
      expect(interaction.isValid()).toBe(true);
    });

    test('isValid should return false for invalid type', () => {
      const interaction = new Interaction({
        user_id: 1,
        interaction_type: 'bad_type',
        item_id: '123',
        item_type: 'place'
      });
      expect(interaction.isValid()).toBe(false);
    });

    test('toDB should format data correctly', () => {
      const data = { foo: 'bar' };
      const interaction = new Interaction({
        user_id: 1,
        interaction_type: 'view',
        item_id: 'abc',
        item_type: 'event',
        interaction_data: data
      });
      
      const dbRow = interaction.toDB();
      expect(JSON.parse(dbRow.interaction_data)).toEqual(data);
    });
  });
});
