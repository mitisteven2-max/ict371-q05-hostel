-- ICT371 Q5 (c): pr_allocate_room
CREATE OR REPLACE PROCEDURE pr_allocate_room(
    p_student_id   INTEGER,
    p_room_id      INTEGER,
    p_allocated_on DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_allocated_on IS NULL THEN
        RAISE EXCEPTION 'Allocation date is required';
    END IF;

    -- Lock student then room (same order every time) so concurrent calls
    -- cannot double-book a student or overfill a room
    PERFORM 1 FROM students WHERE student_id = p_student_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown student_id: %', p_student_id;
    END IF;

    PERFORM 1 FROM rooms WHERE room_id = p_room_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown room_id: %', p_room_id;
    END IF;

    IF EXISTS (SELECT 1 FROM allocations
               WHERE student_id = p_student_id AND status = 'ACTIVE') THEN
        RAISE EXCEPTION 'Student % already has an ACTIVE allocation', p_student_id;
    END IF;

    IF fn_free_beds(p_room_id) <= 0 THEN
        RAISE EXCEPTION 'Room % is full', p_room_id;
    END IF;

    INSERT INTO allocations (student_id, room_id, allocated_on, released_on, status)
    VALUES (p_student_id, p_room_id, p_allocated_on, NULL, 'ACTIVE');
END;
$$;
