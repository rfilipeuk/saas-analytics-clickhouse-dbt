-- Fixed YoY comparison: fills in months with ZERO churn so LAG(12) works correctly

WITH date_range AS (
    -- Step 1: build a complete list of every month between the min and max churn dates in the data
    SELECT
        -- arrayJoin() takes an array and turns it into multiple rows, one row per array element.
        -- Compbined with a generated array of months, this gives us a complete list of months between the min and max churn dates in the data.
        arrayJoin(
            arrayMap(
                x -> toStartOfMonth(addMonths((SELECT min(end_date) FROM subscriptions WHERE end_date IS NOT NULL), x)),
                range(
                    dateDiff('month',
                        (SELECT min(end_date) FROM subscriptions WHERE end_date IS NOT NULL),
                        (SELECT max(end_date) FROM subscriptions WHERE end_date IS NOT NULL)
                    ) + 1
                )
            )
        ) AS calendar_month
),
monthly_churn AS (
    -- Step 2: real churn counts per month 
    SELECT
        toStartOfMonth(end_date) AS churn_month,
        count() AS churned_count
    FROM subscriptions
    WHERE end_date IS NOT NULL
        AND plan = 'pro'
    GROUP BY churn_month
),
filled AS (
    -- Step 3: LEFT JOIN the full calendar to real churn data.
    -- Months with no matching churn row get NULL, which we convert to 0 with COALESCE().
    SELECT
        date_range.calendar_month AS churn_month,
        coalesce(monthly_churn.churned_count, 0) AS churned_count
    FROM date_range
    LEFT JOIN monthly_churn ON date_range.calendar_month = monthly_churn.churn_month
),
yoy AS (
    SELECT
        churn_month,
        churned_count,
        -- Now LAG(12) is reliable: with zero gaps, 12 rows back = 12 months back. 
        nullIf(lag(churned_count, 12) OVER (ORDER BY churn_month), 0) AS same_month_last_year
    FROM filled
)
SELECT
    churn_month,
    churned_count,
    same_month_last_year,
    churned_count - same_month_last_year AS yoy_change,
    round((churned_count - same_month_last_year) / same_month_last_year * 100, 1) AS yoy_change_pct
FROM yoy
ORDER BY churn_month;