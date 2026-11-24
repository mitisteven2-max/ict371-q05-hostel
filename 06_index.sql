-- ICT371 Q5 (f): partial index on ACTIVE allocations by room
CREATE INDEX IF NOT EXISTS idx_alloc_active_room
    ON allocations (room_id)
    WHERE status = 'ACTIVE';

ANALYZE allocations;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT allocation_id, student_id
FROM allocations
WHERE room_id = 1
  AND status = 'ACTIVE';

RESET enable_seqscan;
