module.exports = {
  testEnvironment: 'node',
  verbose: true,
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/tests/',
    '/config/',
    '/scripts/'
  ],
  testTimeout: 10000,
  setupFilesAfterEnv: ['./tests/setup.js']
};
