-- Add the variant column to the existing users table (ALTER, not recreate)
ALTER TABLE users ADD COLUMN variant String