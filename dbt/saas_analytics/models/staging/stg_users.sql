-- Staging model: cleans up raw users data.

SELECT
    user_id,
    signup_date,
    plan,
    country,
    variant
FROM {{ source('raw', 'users') }}