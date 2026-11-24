-- ICT371 Q5 (g): pr_refresh_occupancy + pg_cron
CREATE OR REPLACE PROCEDURE pr_refresh_occupancy()
LANGUAGE plpgsql
AS $$
BEGIN
    -- One row per (date, room); rerunning replaces the values
    INSERT INTO occupancy_snapshot (snapshot_date, room_id, occupied_beds, free_beds)
    SELECT CURRENT_DATE,
           r.room_id,
           COUNT(a.allocation_id)::INTEGER,
           (r.capacity - COUNT(a.allocation_id))::INTEGER
    FROM rooms r
    LEFT JOIN allocations a
           ON a.room_id = r.room_id AND a.status = 'ACTIVE'
    GROUP BY r.room_id, r.capacity
    ON CONFLICT (snapshot_date, room_id) DO UPDATE
    SET occupied_beds = EXCLUDED.occupied_beds,
        free_beds     = EXCLUDED.free_beds;
END;
$$;

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Daily at 23:55
SELECT cron.schedule(
    'q05_occupancy_daily',
    '55 23 * * *',
    $$CALL pr_refresh_occupancy()$$
);

-- Inspect:
-- SELECT jobid, jobname, schedule, command FROM cron.job;
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 5;
