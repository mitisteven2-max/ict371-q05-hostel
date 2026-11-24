-- ICT371 Q5 (d): enforce the rules for direct SQL too
CREATE OR REPLACE FUNCTION trg_fn_allocation_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacity INTEGER;
    v_taken    INTEGER;
BEGIN
    IF NEW.status = 'ACTIVE' THEN
        -- One ACTIVE allocation per student (exclude the row being updated)
        IF EXISTS (
            SELECT 1 FROM allocations a
            WHERE a.student_id = NEW.student_id
              AND a.status = 'ACTIVE'
              AND (TG_OP = 'INSERT' OR a.allocation_id <> NEW.allocation_id)
        ) THEN
            RAISE EXCEPTION 'Student % already has an ACTIVE allocation', NEW.student_id;
        END IF;

        -- Capacity (lock the room row; exclude the row being updated)
        SELECT capacity INTO v_capacity FROM rooms WHERE room_id = NEW.room_id FOR UPDATE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Unknown room_id: %', NEW.room_id;
        END IF;

        SELECT COUNT(*) INTO v_taken
        FROM allocations a
        WHERE a.room_id = NEW.room_id
          AND a.status = 'ACTIVE'
          AND (TG_OP = 'INSERT' OR a.allocation_id <> NEW.allocation_id);

        IF v_taken >= v_capacity THEN
            RAISE EXCEPTION 'Room % is full (capacity %)', NEW.room_id, v_capacity;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_allocation_rules ON allocations;

CREATE TRIGGER trg_allocation_rules
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW
EXECUTE FUNCTION trg_fn_allocation_rules();

-- Concurrency backstop for the one-ACTIVE-per-student rule
CREATE UNIQUE INDEX IF NOT EXISTS uq_one_active_per_student
    ON allocations (student_id)
    WHERE status = 'ACTIVE';
