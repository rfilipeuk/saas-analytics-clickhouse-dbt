-- Top feature used per plan, ranked by usage count 

SELECT
    s.plan, 
    e.feature_name,
    count() AS usage_count
FROM events AS e
INNER JOIN subscriptions AS s ON e.user_id = s.user_id
WHERE e.event_type = 'feature_use'
    AND e.feature_name != ''
GROUP BY s.plan, e.feature_name
ORDER BY s.plan, usage_count DESC