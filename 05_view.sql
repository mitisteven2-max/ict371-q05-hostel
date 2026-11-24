-- ICT371 Q5 (e): v_room_occupancy (LEFT JOIN keeps rooms with no allocations)
CREATE OR REPLACE VIEW v_room_occupancy AS
SELECT r.room_id,
       r.room_number,
       r.capacity,
       COUNT(a.allocation_id)              AS occupied_beds,
       r.capacity - COUNT(a.allocation_id) AS free_beds
FROM rooms r
LEFT JOIN allocations a
       ON a.room_id = r.room_id
      AND a.status = 'ACTIVE'          -- in the ON clause so empty rooms survive
GROUP BY r.room_id, r.room_number, r.capacity
ORDER BY r.room_number;
