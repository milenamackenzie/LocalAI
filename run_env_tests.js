const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const REPORT_PATH = path.join(__dirname, 'env_test_report.html');

console.log('Starting Environment Verification...');

let results = {
    backend: { status: 'PENDING', output: '', passed: false },
    frontend: { status: 'PENDING', output: '', passed: false }
};

function generateHtml() {
    const html = `
<!DOCTYPE html>
<html>
<head>
    <title>LocalAI Environment Verification Report</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 20px; background: #f0f2f5; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #1a1a1a; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .summary { display: flex; gap: 20px; margin-bottom: 20px; }
        .card { flex: 1; padding: 15px; border-radius: 6px; color: white; }
        .pass { background: #28a745; }
        .fail { background: #dc3545; }
        pre { background: #1e1e1e; color: #d4d4d4; padding: 15px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; }
        .section-title { font-weight: bold; margin-top: 20px; font-size: 1.2em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Environment Verification Report</h1>
        <p>Generated: ${new Date().toLocaleString()}</p>
        
        <div class="summary">
            <div class="card ${results.backend.passed ? 'pass' : 'fail'}">
                Backend Tests: ${results.backend.passed ? 'PASSED' : 'FAILED'}
            </div>
            <div class="card ${results.frontend.passed ? 'pass' : 'fail'}">
                Frontend Tests: ${results.frontend.passed ? 'PASSED' : 'FAILED'}
            </div>
        </div>

        <div class="section-title">Backend (Jest) Output</div>
        <pre>${results.backend.output || 'No output'}</pre>

        <div class="section-title">Frontend (Flutter Test) Output</div>
        <pre>${results.frontend.output || 'No output'}</pre>
        
        <div class="section-title">Remediation Steps</div>
        <ul>
            ${!results.backend.passed ? '<li><strong>Backend Failed:</strong> Run "npm install" in backend/. Check Node.js version. Check "environment.test.js" for specific errors.</li>' : ''}
            ${!results.frontend.passed ? '<li><strong>Frontend Failed:</strong> Run "flutter doctor". Check Android SDK setup.</li>' : ''}
        </ul>
    </div>
</body>
</html>`;
    
    fs.writeFileSync(REPORT_PATH, html);
    console.log(`Report generated at: ${REPORT_PATH}`);
}

function runBackend() {
    return new Promise(resolve => {
        console.log('Running Backend Tests...');
        // Use shell: true for better Windows compatibility
        const cmd = 'npm';
        const proc = spawn(cmd, ['test', '--', 'tests/environment.test.js'], { 
            cwd: path.join(__dirname, 'backend'),
            env: { ...process.env, CI: 'true' },
            shell: true
        });

        let output = '';
        proc.stdout.on('data', d => output += d);
        proc.stderr.on('data', d => output += d);

        proc.on('close', (code) => {
            results.backend.passed = (code === 0);
            results.backend.output = output.replace(/\x1B\[\d+m/g, ''); // Strip ANSI colors
            console.log(`Backend finished with code ${code}`);
            resolve();
        });
    });
}

function runFrontend() {
    return new Promise(resolve => {
        console.log('Running Frontend Tests...');
        // Requires flutter in PATH. If using local install, specify full path
        let cmd = 'flutter';
        // Try to find flutter if not in path (fallback logic similar to verify script)
        if (!process.env.PATH.includes('flutter')) {
            if (process.platform === 'win32' && fs.existsSync('C:\\src\\flutter\\bin\\flutter.bat')) {
                 cmd = 'C:\\src\\flutter\\bin\\flutter.bat';
            }
        }

        const proc = spawn(cmd, ['test', 'test/environment_test.dart'], {
            cwd: path.join(__dirname, 'frontend'),
            env: process.env,
            shell: true
        });

        let output = '';
        proc.stdout.on('data', d => output += d);
        proc.stderr.on('data', d => output += d);

        proc.on('close', (code) => {
            results.frontend.passed = (code === 0);
            results.frontend.output = output.replace(/\x1B\[\d+m/g, '');
            console.log(`Frontend finished with code ${code}`);
            resolve();
        });
        
        proc.on('error', (err) => {
             results.frontend.output = `Failed to spawn flutter: ${err.message}`;
             resolve();
        });
    });
}

async function main() {
    await runBackend();
    await runFrontend();
    generateHtml();
}

main();
