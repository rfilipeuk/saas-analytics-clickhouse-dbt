-- DAU / WAU / MAU: Daily, Weekly, and Monthly Active Users.
--   DAU = users active on THIS exact day
--   WAU = users active at any point in the 7 days ending on this date (rolling)
--   MAU = users active at any point in the 30 days ending on this date (rolling)
--
-- Approach: build a "date spine" (one row per calendar day), then for each
-- spine date, JOIN against events that fall inside the relevant rolling window.
-- This avoids referencing a GROUP BY alias inside an aggregate function,
-- which ClickHouse (and most SQL engines) doesn't allow.

WITH date_spine AS (
    -- Step 1: one row per day, covering the full range of our event data.
    -- Same arrayJoin/arrayMap/range pattern used earlier for the YoY calendar.
    SELECT
        arrayJoin(
            arrayMap(
                x -> toDate(addDays((SELECT min(toDate(event_time)) FROM events), x)),
                range(
                    dateDiff('day',
                        (SELECT min(toDate(event_time)) FROM events),
                        (SELECT max(toDate(event_time)) FROM events)
                    ) + 1
                )
            )
        ) AS activity_date
),

dau AS (
    -- Step 2: DAU is a simple GROUP BY, no rolling window needed
    SELECT
        toDate(event_time) AS activity_date,
        uniqExact(user_id) AS dau
    FROM events
    GROUP BY activity_date
),

wau AS (
    -- Step 3: for each spine date, join events within the last 7 days
    -- (6 days back + the day itself = 7-day window) and count distinct users
    SELECT
        ds.activity_date,
        uniqExact(e.user_id) AS wau
    FROM date_spine AS ds
    LEFT JOIN events AS e
        ON toDate(e.event_time) BETWEEN ds.activity_date - INTERVAL 6 DAY AND ds.activity_date
    GROUP BY ds.activity_date
),

mau AS (
    -- Step 4: same idea, but a 30-day window instead of 7
    SELECT
        ds.activity_date,
        uniqExact(e.user_id) AS mau
    FROM date_spine AS ds
    LEFT JOIN events AS e
        ON toDate(e.event_time) BETWEEN ds.activity_date - INTERVAL 29 DAY AND ds.activity_date
    GROUP BY ds.activity_date
)

-- Step 5: combine all three metrics into one row per day.
-- coalesce(dau, 0) handles days with zero activity (no matching row in `dau`).
SELECT
    ds.activity_date,
    coalesce(dau.dau, 0) AS dau,
    wau.wau,
    mau.mau
FROM date_spine AS ds
LEFT JOIN dau ON ds.activity_date = dau.activity_date
LEFT JOIN wau ON ds.activity_date = wau.activity_date
LEFT JOIN mau ON ds.activity_date = mau.activity_date
ORDER BY ds.activity_date
LIMIT 30