-- Recommendation System Enhancements
ALTER TABLE recommendations ADD COLUMN category TEXT;
ALTER TABLE recommendations ADD COLUMN generation_context TEXT; -- JSON: context used to generate
ALTER TABLE recommendations ADD COLUMN feedback_status TEXT; -- 'liked', 'disliked', 'none'
ALTER TABLE recommendations ADD COLUMN is_archived INTEGER DEFAULT 0;

-- Create index for filtering
CREATE INDEX IF NOT EXISTS idx_recommendations_category ON recommendations(category);
CREATE INDEX IF NOT EXISTS idx_recommendations_score ON recommendations(recommendation_score DESC);
