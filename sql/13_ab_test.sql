-- A/B test: does variant B (new onboarding) improve signup-> login conversion?

WITH total_by_variant AS (
    -- total users per varient, no JOIN needed here 
    SELECT variant, uniqExact(user_id) AS total_users
    FROM users
    GROUP BY variant
),
logged_in_by_variant AS (
    -- users who logged in, Joined to their variant, counted separately
    SELECT u.variant, uniqExact(e.user_id) AS users_who_logged_in
    FROM events AS e
    INNER JOIN users AS u ON e.user_id = u.user_id
    WHERE e.event_type = 'login'
    GROUP BY u.variant
)
SELECT 
    t.variant,
    t.total_users,
    l.users_who_logged_in,
    round(l.users_who_logged_in / t.total_users * 100, 1) AS login_conversion_pct
FROM total_by_variant AS t
INNER JOIN logged_in_by_variant AS l ON t.variant = l.variant
ORDER BY t.variant