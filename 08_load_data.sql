-- ICT371 Q5 (a): allocations (ACTIVE ones go through the procedure)
CALL pr_allocate_room(1, 1, DATE '2026-09-01');   -- R101: 2 of 2 => full
CALL pr_allocate_room(2, 1, DATE '2026-09-01');
CALL pr_allocate_room(3, 2, DATE '2026-09-02');   -- R102: 1 of 3 => partly occupied

-- History: ENDED allocations do not occupy beds. R103 stays empty.
INSERT INTO allocations (student_id, room_id, allocated_on, released_on, status) VALUES
    (4, 3, DATE '2026-03-01', DATE '2026-07-01', 'ENDED'),
    (5, 1, DATE '2026-02-01', DATE '2026-06-30', 'ENDED');
