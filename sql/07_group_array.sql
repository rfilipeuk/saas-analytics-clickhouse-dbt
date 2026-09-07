-- groupArray(): collects values from multiple rows into a single Array per group
-- HERE: for each user, buid an ordered list of all their event types over time.
-- Useful for debugging user journeys, building funnels visually, or feeding
-- sequence data into further analysis

SELECT
    user_id,

    -- groupArray(x) collects every value of x within the group into one array.
    -- Since we sort by event_time first (see subquery below), the array preserves chrological order
    groupArray(event_type) AS event_sequence,

    -- Bonus: count how many events this user has in total.
    length(groupArray(event_type)) AS total_events

FROM
(
    -- Subquery: Clickhouse doesn't guarantee the order of rows in a table
    -- unless the input rows are already sorted. So we sort by event_time
    -- BEFORE grouping, ensuring the sequence reflects real chronological order.
    SELECT user_id, event_type, event_time
    FROM events
    ORDER BY user_id, event_time
)
GROUP BY user_id
ORDER BY total_events DESC
LIMIT 10;