const fs = require('fs');
const path = require('path');
const net = require('net');
const sqlite3 = require('sqlite3').verbose();
const { execSync } = require('child_process');

describe('Backend Environment Verification', () => {
  const REQUIRED_NODE_MAJOR = 24;
  const DB_PATH = path.resolve(__dirname, '../localai.db');
  
  test('Node.js version should be v24+', () => {
    const currentVersion = process.version;
    const majorVersion = parseInt(currentVersion.substring(1).split('.')[0], 10);
    
    if (majorVersion < REQUIRED_NODE_MAJOR) {
      throw new Error(`Current Node.js version ${currentVersion} is below required v${REQUIRED_NODE_MAJOR}. Remediation: Upgrade Node.js from https://nodejs.org/`);
    }
    expect(majorVersion).toBeGreaterThanOrEqual(REQUIRED_NODE_MAJOR);
  });

  test('Project structure should be valid', () => {
    const requiredDirs = ['src', 'src/config', 'src/controllers', 'src/models'];
    requiredDirs.forEach(dir => {
      const fullPath = path.resolve(__dirname, '..', dir);
      if (!fs.existsSync(fullPath)) {
        throw new Error(`Missing directory: ${dir}. Remediation: Run project scaffold script.`);
      }
      expect(fs.existsSync(fullPath)).toBe(true);
    });
  });

  test('File system should be writable', () => {
    const testFile = path.resolve(__dirname, '../write_test.tmp');
    try {
      fs.writeFileSync(testFile, 'test');
      fs.unlinkSync(testFile);
    } catch (error) {
      throw new Error(`File system not writable: ${error.message}. Remediation: Check directory permissions.`);
    }
  });

  test('SQLite should be functional', (done) => {
    const db = new sqlite3.Database(DB_PATH, (err) => {
      if (err) {
        done(new Error(`SQLite Connection Failed: ${err.message}. Remediation: Check file permissions or reinstall sqlite3.`));
        return;
      }
      
      db.run("CREATE TABLE IF NOT EXISTS test_env (id INT)", (runErr) => {
        if (runErr) {
          db.close();
          done(new Error(`SQLite Write Failed: ${runErr.message}`));
          return;
        }
        db.close(done);
      });
    });
  });

  test('Port 3000 should be available', (done) => {
    const server = net.createServer();
    server.once('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        done(new Error('Port 3000 is already in use. Remediation: Kill the process using port 3000 or change PORT env var.'));
      } else {
        done(err);
      }
    });
    
    server.once('listening', () => {
      server.close();
      done();
    });
    
    server.listen(3000);
  });

  test('Git should be configured', () => {
    try {
      const userName = execSync('git config user.name').toString().trim();
      const userEmail = execSync('git config user.email').toString().trim();
      
      if (!userName || !userEmail) {
        throw new Error('Git user/email not configured');
      }
    } catch (error) {
      throw new Error(`Git configuration missing. Remediation: Run "git config --global user.name 'Your Name'" and "git config --global user.email 'you@example.com'"`);
    }
  });

  test('Performance: Memory usage should be within limits', () => {
    const used = process.memoryUsage().heapUsed / 1024 / 1024;
    // Arbitrary limit for an empty env check
    if (used > 200) { 
        throw new Error(`High memory usage detected: ${Math.round(used)}MB`); 
    }
    expect(used).toBeLessThan(500);
  });
});
