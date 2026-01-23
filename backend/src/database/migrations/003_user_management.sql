-- User Management Enhancements
ALTER TABLE users ADD COLUMN avatar_url TEXT;
ALTER TABLE users ADD COLUMN deleted_at DATETIME;

-- Preferences - Ensure unique constraint on user_id + category exists (already in 001 but good to confirm or add specific categories check if needed)
-- (Already handled in 001: CREATE UNIQUE INDEX IF NOT EXISTS idx_user_preferences_unique ON user_preferences(user_id, category);)
