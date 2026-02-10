const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

async function runStressTest() {
    const dbPath = path.resolve(__dirname, '../../localai_stress.db');
    if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);

    const db = new sqlite3.Database(dbPath);
    console.log('Starting SQLite Stress Test (10,000+ interactions)...');

    return new Promise((resolve, reject) => {
        db.serialize(() => {
            db.run(`CREATE TABLE user_interactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                interaction_type TEXT NOT NULL,
                item_id TEXT NOT NULL,
                item_type TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )`);

            const stmt = db.prepare("INSERT INTO user_interactions (user_id, interaction_type, item_id, item_type) VALUES (?, ?, ?, ?)");
            
            const start = Date.now();
            db.run("BEGIN TRANSACTION");
            for (let i = 0; i < 10000; i++) {
                stmt.run(1, 'view', `item_${i}`, 'location');
            }
            db.run("COMMIT", (err) => {
                if (err) return reject(err);
                
                const end = Date.now();
                const duration = end - start;
                console.log(`Inserted 10,000 rows in ${duration}ms`);

                // Query test
                const queryStart = Date.now();
                db.all("SELECT COUNT(*) as count FROM user_interactions", [], (err, rows) => {
                    const queryEnd = Date.now();
                    console.log(`Query "COUNT(*)" took ${queryEnd - queryStart}ms. Total rows: ${rows[0].count}`);
                    
                    db.close();
                    fs.unlinkSync(dbPath);
                    resolve();
                });
            });
            stmt.finalize();
        });
    });
}

runStressTest().catch(console.error);
