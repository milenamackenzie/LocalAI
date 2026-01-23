const autocannon = require('autocannon');
const path = require('path');

async function runLoadTest() {
    console.log('Starting Performance Benchmark (Load Test)...');
    
    const result = await autocannon({
        url: 'http://localhost:3000/api/v1/health',
        connections: 100, // Simulate 100 concurrent users
        duration: 10,     // 10 seconds duration
        pipelining: 1,
        title: 'Health Check Load Test'
    });

    console.log('--- Results ---');
    console.log(`Requests/sec: ${result.requests.average}`);
    console.log(`Latency (ms): ${result.latency.average}`);
    console.log(`Errors: ${result.errors}`);
    console.log(`Timeouts: ${result.timeouts}`);
    
    if (result.errors > 0) {
        process.exit(1);
    }
}

// Check if server is running before starting
const http = require('http');
const req = http.get('http://localhost:3000/api/v1/health', (res) => {
    runLoadTest();
}).on('error', (e) => {
    console.error('Error: Server must be running on port 3000 to run performance tests.');
    process.exit(1);
});
