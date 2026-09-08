-- Staging model: cleans up raw events data, no business logic yet.

SELECT
    event_id,
    user_id,
    event_type,
    event_time,
    -- treat empty string as NULL for consistency
    nullIf(feature_name, '') AS feature_name
FROM {{ source('raw', 'events') }}
