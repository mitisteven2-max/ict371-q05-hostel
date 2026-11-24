-- ICT371 Q5 (b): fn_free_beds (only ACTIVE allocations occupy beds)
CREATE OR REPLACE FUNCTION fn_free_beds(p_room_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_capacity INTEGER;
    v_active   INTEGER;
BEGIN
    SELECT capacity INTO v_capacity FROM rooms WHERE room_id = p_room_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown room_id: %', p_room_id;
    END IF;

    SELECT COUNT(*) INTO v_active
    FROM allocations
    WHERE room_id = p_room_id
      AND status = 'ACTIVE';

    RETURN v_capacity - v_active;
END;
$$;
