const fs = require('fs');
const path = require('path');

const resultsFile = path.join(__dirname, 'validation-results.json');
const reportFile = path.join(__dirname, 'RELEVANCE-REPORT.html');

if (!fs.existsSync(resultsFile)) {
    console.error('No validation results found. Run the tests first.');
    process.exit(1);
}

const results = JSON.parse(fs.readFileSync(resultsFile, 'utf8'));

const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recommendation Validation Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; max-width: 1000px; margin: 0 auto; padding: 20px; background-color: #f4f7f6; }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .summary { display: flex; gap: 20px; margin-bottom: 30px; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; text-align: center; }
        .card h2 { margin-top: 0; font-size: 1.2rem; color: #7f8c8d; }
        .card .value { font-size: 2.5rem; font-weight: bold; color: #2c3e50; }
        .pass { color: #27ae60; }
        .fail { color: #e74c3c; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #3498db; color: white; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 1px; }
        tr:hover { background-color: #f9f9f9; }
        .status-pill { padding: 4px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: bold; }
        .status-pass { background-color: #d4edda; color: #155724; }
        .status-fail { background-color: #f8d7da; color: #721c24; }
        .details { font-size: 0.9rem; color: #666; font-style: italic; }
    </style>
</head>
<body>
    <h1>Recommendation Validation Report</h1>
    <p>Generated on: ${new Date().toLocaleString()}</p>

    <div class="summary">
        <div class="card">
            <h2>Total Tests</h2>
            <div class="value">${results.length}</div>
        </div>
        <div class="card">
            <h2>Passed</h2>
            <div class="value pass">${results.filter(r => r.passed).length}</div>
        </div>
        <div class="card">
            <h2>Failed</h2>
            <div class="value fail">${results.filter(r => !r.passed).length}</div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Test Scenario</th>
                <th>Metric</th>
                <th>Result</th>
                <th>Status</th>
                <th>Details</th>
            </tr>
        </thead>
        <tbody>
            ${results.map(r => `
                <tr>
                    <td><strong>${r.test}</strong></td>
                    <td>${r.metric || '-'}</td>
                    <td>${r.value || (r.passed ? 'PASSED' : 'FAILED')}</td>
                    <td><span class="status-pill ${r.passed ? 'status-pass' : 'status-fail'}">${r.passed ? 'PASS' : 'FAIL'}</span></td>
                    <td class="details">${r.details || ''}</td>
                </tr>
            `).join('')}
        </tbody>
    </table>

    <div style="margin-top: 30px; padding: 20px; background: #ebedef; border-radius: 8px;">
        <h3>A/B Testing Methodology</h3>
        <p>Traditional recommendations are matched against user interest categories from a static catalog. Hybrid recommendations utilize local AI re-ranking and generation to provide more personalized and diverse suggestions.</p>
    </div>
</body>
</html>
`;

fs.writeFileSync(reportFile, html);
console.log(`Report generated successfully: ${reportFile}`);
