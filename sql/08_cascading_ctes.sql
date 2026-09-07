-- Cascading CTEs (STACKING): chain multiple CTEs wohere each one builds on the result of the previous one, 
-- instead of nesting subqueries inside subqueries. 

-- Goal: Flag "at-risk" users -> active paid subscribers whose engagement (login) has dropped off in the last 30 days vs their lifetime average.

WITH user_last_event AS (
    -- Layer 1: find the last event for each user
    SELECT
        user_id,
        max(event_time) AS last_event_time
    FROM events
    GROUP BY user_id
),

user_engagement AS (
    -- Layer 2: buids on layer 1. For each user, count logins in their last 30 days vs their lifetime logins
    SELECT
        e.user_id,
        ule.last_event_time,

        -- Lifetime logins
        countIf(e.event_type = 'login') AS lifetime_logins,

        -- Logins in the last 30 days
        countIf(
            e.event_type = 'login'
            AND e.event_time >= ule.last_event_time - INTERVAL 30 DAY
        ) AS recent_logins
    FROM events AS e
    INNER JOIN user_last_event AS ule ON e.user_id = ule.user_id
    GROUP BY e.user_id, ule.last_event_time
),

user_engagement_ratio AS (
    -- Layer 3: builds on layer 2. Turn raw counts into a comparable ratio:
    -- What share of user's total logins happened recently?
    -- A LOW ratio (recent activity is a small share of lifetime activity) can signal a user is at risk of churn.
    SELECT
        user_id,
        lifetime_logins,
        recent_logins,
        -- nullIf avoids divide by zero for users with 0 lifetime logins
        round(recent_logins / nullIf(lifetime_logins, 0) * 100, 1) AS recent_activity_pct
    FROM user_engagement
),

active_paid_subs AS (
    -- Layer 4a: separately, get currently active paid subscriptions (end_date IS NULL means the subscription is still active)
    SELECT user_id, plan, mrr
    FROM subscriptions
    WHERE end_date IS NULL
        AND plan != 'free'
)

-- Final layer: join engagement ratio (layer 3) with active paid subs (Layer 4a) to flag at-risk users.
SELECT
    aps.user_id,
    aps.plan,
    aps.mrr,
    uer.lifetime_logins,
    uer.recent_logins,
    uer.recent_activity_pct,
    -- Simple business rule: if recent activity is less than 20% of lifetime activity, flag as at-risk.
    if(uer.recent_activity_pct < 20 AND uer.lifetime_logins >= 10, 'at-risk', 'healthy') AS churn_risk_flag
FROM active_paid_subs AS aps
INNER JOIN user_engagement_ratio AS uer ON aps.user_id = uer.user_id
ORDER BY uer.recent_activity_pct ASC
LIMIT 20;