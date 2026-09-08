-- Staging model: cleans up raw subscriptions data.

SELECT
    subscription_id,
    user_id,
    plan,
    start_date,
    end_date,
    mrr,
    -- derived boolean flag: easier to filter on than "end_date IS NOT NULL" everywhere downstream
    end_date IS NOT NULL AS is_churned
FROM {{ source('raw', 'subscriptions') }}
