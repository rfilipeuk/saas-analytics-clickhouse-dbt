-- Date filters: common patterns for filtering time_series data in dashboarding and reporting
-- Pattern 1: relative rolling window ("last 90 days" from today)

SELECT count() AS events_last_90_days
FROM events
WHERE event_time >= now() - INTERVAL 90 DAY

-- Pattern 2: current calendar month ( from day 1 of this month to today) toStartMonth(now()) gives the first day of the current month

-- Pattern 3: a FIXED historical window (more useful for synthetic dataset) Filtering to a specific quarter 

SELECT 
    count() AS events_in_q3_2025
FROM events
WHERE event_time >= toDateTime('2025-07-01 00:00:00') 
    AND event_time < toDateTime('2025-10-01 00:00:00')

-- Pattern 4: "same period last year" filter, useful for YoY dashboards combined with a variable/parameter in a real BI tool.
SELECT 
    count() AS events_q3_2024
FROM events
WHERE event_time >= toDateTime('2024-07-01 00:00:00')
    AND event_time < toDateTime('2024-10-01 00:00:00')