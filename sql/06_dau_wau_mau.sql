-- DAU / WAU / MAU: Daily, Weekly, and Monthly Active Users.
-- "Active" here = generated at least one event (login, feature_use, etc.) in that period.

SELECT
    -- toDate() truncates a DateTime down to just the Date (drops the time-of-day part)
    toDate(event_time) AS activity_date,

    -- DAU: distinct users active on this exact day
    uniqExact(user_id) AS dau

FROM events
GROUP BY activity_date
ORDER BY activity_date
-- just peek at the first 20 days for now
LIMIT 20