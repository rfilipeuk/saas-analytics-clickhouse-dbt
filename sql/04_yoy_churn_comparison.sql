-- Year-over-Year Churn Comparison
-- Goal: compare each month's churn to the same month one year earlier

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
yoy AS (
    SELECT
        churn_month,
        churned_count,
        -- LAG(column, 12) looks back 12 ROW in the result, which only equals the same month one year earlier. This is the key to YoY comparison.  
        nullIf(lag(churned_count, 12) OVER (ORDER BY churn_month), 0) AS same_month_last_year
    FROM monthly_churn
)
SELECT
    churn_month,
    churned_count,
    same_month_last_year,
    churned_count - same_month_last_year AS yoy_change,
    round((churned_count - same_month_last_year) / same_month_last_year * 100, 1) AS yoy_change_pct
FROM yoy
ORDER BY churn_month;