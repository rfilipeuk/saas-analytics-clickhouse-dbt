-- Churn analysis: how many subscriptions ended, broken down by month and plan.

WITH monthly_churn AS (
    -- toStartOfMonth() rounds a date down to the 1st of its month — a core
    -- ClickHouse date-bucketing function, same family as "toStartOf..." in your list.
    SELECT
        toStartOfMonth(end_date) AS churn_month,
        plan,
        count() AS churned_count
    FROM subscriptions
    WHERE end_date IS NOT NULL   
      AND plan != 'free'         
    GROUP BY churn_month, plan
)
SELECT
    churn_month,
    plan,
    churned_count
FROM monthly_churn

HAVING churned_count > 2
ORDER BY churn_month, plan;