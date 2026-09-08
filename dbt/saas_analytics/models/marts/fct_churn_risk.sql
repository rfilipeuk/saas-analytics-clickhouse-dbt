-- Fact model: flags currently active paying users whose recent engagement
-- has dropped sharply vs their lifetime average.

WITH user_last_event AS (
    SELECT user_id, max(event_time) AS last_event_time
    FROM {{ ref('stg_events') }}
    GROUP BY user_id
),

user_engagement AS (
    SELECT
        e.user_id,
        ule.last_event_time,
        countIf(e.event_type = 'login') AS lifetime_logins,
        countIf(
            e.event_type = 'login'
            AND e.event_time >= ule.last_event_time - INTERVAL 30 DAY
        ) AS recent_logins
    FROM {{ ref('stg_events') }} AS e
    INNER JOIN user_last_event AS ule ON e.user_id = ule.user_id
    GROUP BY e.user_id, ule.last_event_time
),

user_engagement_ratio AS (
    SELECT
        user_id,
        lifetime_logins,
        recent_logins,
        round(recent_logins / nullIf(lifetime_logins, 0) * 100, 1) AS recent_activity_pct
    FROM user_engagement
),

active_paid_subs AS (
    SELECT user_id, plan, mrr
    FROM {{ ref('stg_subscriptions') }}
    WHERE NOT is_churned
      AND plan != 'free'
)

SELECT
    aps.user_id,
    aps.plan,
    aps.mrr,
    uer.lifetime_logins,
    uer.recent_logins,
    uer.recent_activity_pct,
    if(uer.recent_activity_pct < 20 AND uer.lifetime_logins >= 10, 'at_risk', 'healthy') AS churn_risk_flag
FROM active_paid_subs AS aps
INNER JOIN user_engagement_ratio AS uer ON aps.user_id = uer.user_id