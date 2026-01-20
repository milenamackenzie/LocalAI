const authController = require('../../src/controllers/authController');
const authValidator = require('../../src/validators/authValidator');
const validate = require('../../src/middleware/validate');
const { validationResult } = require('express-validator');

// Mock request and response
const mockRequest = (body) => ({
    body,
});
const mockResponse = () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

describe('Auth Validation Rules', () => {
    
    // Helper to run express-validator chains
    const runValidation = async (validators, req) => {
        for (const validator of validators) {
            await validator.run(req);
        }
        return validationResult(req);
    };

    describe('Registration Validation', () => {
        test('Should fail if email is invalid', async () => {
            const req = { body: { username: 'validUser', email: 'bad-email', password: 'Valid1@Password' } };
            const result = await runValidation(authValidator.registerValidators, req);
            
            expect(result.isEmpty()).toBe(false);
            expect(result.array()[0].msg).toContain('Invalid email format');
        });

        test('Should fail if password is weak', async () => {
            const req = { body: { username: 'validUser', email: 'test@test.com', password: 'weak' } };
            const result = await runValidation(authValidator.registerValidators, req);
            
            expect(result.isEmpty()).toBe(false);
            // Should have multiple errors usually, just checking one existence
            const msgs = result.array().map(e => e.msg);
            expect(msgs.some(m => m.includes('8 characters'))).toBe(true);
        });

        test('Should fail if username is invalid', async () => {
            const req = { body: { username: 'a', email: 'test@test.com', password: 'Valid1@Password' } };
            const result = await runValidation(authValidator.registerValidators, req);
            
            expect(result.isEmpty()).toBe(false);
            expect(result.array()[0].msg).toContain('between 3 and 30 characters');
        });

        test('Should pass with valid data', async () => {
            const req = { body: { username: 'goodUser', email: 'test@test.com', password: 'Valid1@Password' } };
            const result = await runValidation(authValidator.registerValidators, req);
            
            expect(result.isEmpty()).toBe(true);
        });
    });
});
