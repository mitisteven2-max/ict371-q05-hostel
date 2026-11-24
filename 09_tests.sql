-- (b) free beds: R101 = 0 (ended rows ignored), R102 = 2, R103 = 2
SELECT room_id, fn_free_beds(room_id) AS free FROM rooms ORDER BY room_id;
DO $$ BEGIN PERFORM fn_free_beds(999);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (c) rejections: full room, student already active, unknown IDs
DO $$ BEGIN CALL pr_allocate_room(4, 1, CURRENT_DATE);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_allocate_room(3, 3, CURRENT_DATE);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_allocate_room(99, 3, CURRENT_DATE);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (d) direct SQL is also checked
DO $$ BEGIN INSERT INTO allocations (student_id, room_id, allocated_on, status)
            VALUES (4, 1, CURRENT_DATE, 'ACTIVE');                    -- room full
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN INSERT INTO allocations (student_id, room_id, allocated_on, status)
            VALUES (3, 3, CURRENT_DATE, 'ACTIVE');                    -- student already active
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
-- updating a row in a FULL room works: the row being updated is excluded from the count
UPDATE allocations SET allocated_on = allocated_on WHERE allocation_id = 1;

-- valid allocation
CALL pr_allocate_room(4, 3, CURRENT_DATE);

-- (e) every room, including empty ones
SELECT * FROM v_room_occupancy;

-- (g) run twice: one row per date and room
CALL pr_refresh_occupancy();
CALL pr_refresh_occupancy();
SELECT * FROM occupancy_snapshot ORDER BY snapshot_date, room_id;

-- (f) EXPLAIN again now that the tables contain data
ANALYZE allocations;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT allocation_id, student_id
FROM allocations
WHERE room_id = 1
  AND status = 'ACTIVE';

RESET enable_seqscan;
