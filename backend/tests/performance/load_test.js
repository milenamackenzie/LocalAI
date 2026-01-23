const autocannon = require('autocannon');
const { spawn } = require('child_process');
const path = require('path');

// Configuration
const DURATION = 10; // seconds
const CONNECTIONS = 100; // concurrent users
const TARGET_URL = 'http://localhost:3000/api/v1';

async function runLoadTest() {
    console.log('Starting Load Test...');
    console.log(`Target: ${TARGET_URL}`);
    console.log(`Concurrent Users: ${CONNECTIONS}`);
    console.log(`Duration: ${DURATION}s`);

    // 1. Health Check Load Test
    const healthTest = await runAutocannon({
        url: `${TARGET_URL}/health`,
        connections: CONNECTIONS,
        duration: DURATION,
        title: 'Health Check Endpoint'
    });

    console.log('Health Check Results:', formatResults(healthTest));

    // 2. Auth Load Test (Simulate Login attempts)
    // Note: Rate limiting will likely kick in here, checking if system handles it gracefully (429s)
    const loginTest = await runAutocannon({
        url: `${TARGET_URL}/auth/login`,
        method: 'POST',
        body: JSON.stringify({ email: 'loadtest@test.com', password: 'Password123!' }),
        headers: { 'content-type': 'application/json' },
        connections: 20, // Lower connections for heavy logic
        duration: DURATION,
        title: 'Login Endpoint'
    });

    console.log('Login Results (Expect 429s):', formatResults(loginTest));
}

function runAutocannon(opts) {
    return new Promise((resolve, reject) => {
        autocannon(opts, (err, result) => {
            if (err) return reject(err);
            resolve(result);
        });
    });
}

function formatResults(result) {
    return {
        requests: {
            total: result.requests.total,
            avg: result.requests.average,
            min: result.requests.min,
            max: result.requests.max
        },
        latency: {
            avg: result.latency.average,
            p99: result.latency.p99
        },
        errors: result.errors,
        timeouts: result.timeouts,
        non2xx: result.non2xx
    };
}

if (require.main === module) {
    runLoadTest();
}
