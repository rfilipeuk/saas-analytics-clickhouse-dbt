-- INNER JOIN: only users that exist in BOTH tables 
SELECT count() AS inner_join_count
FROM users AS u
INNER JOIN subscriptions AS s ON u.user_id = s.user_id

-- LEFT JOIN: all users, even those with no subscription (NULLs on the right side)
SELECT count() AS left_join_count
FROM users AS u
LEFT JOIN subscriptions AS s ON u.user_id = s.user_id

-- LEFT JOIN + filter: user with NO subscription at all
SELECT count() AS users_without_subscription
FROM users AS u
LEFT JOIN subscriptions AS s ON u.user_id = s.user_id
WHERE s.user_id = 0