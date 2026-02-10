const authValidator = require('../../src/validators/authValidator');
const { validationResult } = require('express-validator');

jest.mock('../../src/services/queueService');

describe('Auth Validation Rules', () => {
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
        });

        test('Should pass with valid data', async () => {
            const req = { body: { username: 'goodUser', email: 'test@test.com', password: 'Valid1@Password' } };
            const result = await runValidation(authValidator.registerValidators, req);
            expect(result.isEmpty()).toBe(true);
        });
    });
});
