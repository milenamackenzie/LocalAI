-- Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL, -- Refers to recommendations.id or external id
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    -- If locations are specifically from the recommendations table:
    -- FOREIGN KEY (location_id) REFERENCES recommendations(id) ON DELETE CASCADE,
    UNIQUE(user_id, location_id) -- Prevent duplicate reviews
);

CREATE INDEX IF NOT EXISTS idx_reviews_location ON reviews(location_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id);
