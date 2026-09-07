-- Month-over-Month (MoM) churn comparison.
-- Goal: for each month, show how churn changed vs the previous month.

WITH monthly_churn AS (
    SELECT
        toStartOfMonth(end_date) AS churn_month,
        count() AS churned_count
    FROM subscriptions
    WHERE end_date IS NOT NULL
      AND plan = 'pro'
    GROUP BY churn_month
    ORDER BY churn_month
),
mom AS (
    SELECT
        churn_month,
        churned_count,
        -- nullIf(x, 0) turns a 0 into NULL, so downstream division by zero
        -- becomes "no data" (NULL) instead of a fake number.
        -- This correctly handles the very first month, which has no real "previous month".
        nullIf(lag(churned_count, 1) OVER (ORDER BY churn_month), 0) AS previous_month_churn
    FROM monthly_churn
)
SELECT
    churn_month,
    churned_count,
    previous_month_churn,
    churned_count - previous_month_churn AS mom_change,
    round((churned_count - previous_month_churn) / previous_month_churn * 100, 1) AS mom_change_pct
FROM mom
ORDER BY churn_month;