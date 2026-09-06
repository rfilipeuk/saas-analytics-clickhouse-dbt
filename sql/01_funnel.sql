WITH funnel AS (
    SELECT
        uniqIf(user_id, event_type = 'signup') AS step1_signup,
        uniqIf(user_id, event_type = 'login') AS step2_login,
        uniqIf(user_id, event_type = 'feature_use') AS step3_feature_use
    FROM events
)
SELECT 
    step1_signup,
    step2_login,
    step3_feature_use,
    round(step2_login / step1_signup * 100, 1) AS pct_signup_to_login,
    round(step3_feature_use / step2_login * 100, 1) AS pct_login_to_feature_use,
    round(100 - (step2_login / step1_signup * 100), 1) AS dropoff_signup_to_login,
    round(100 - (step3_feauture_use / ste2_login * 100), 1) AS dropoff_login_to_feature_use
FROM funnel;