-- ICT371 Q5 (a): tables, constraints, students and rooms
DROP TABLE IF EXISTS occupancy_snapshot, allocations, rooms, students CASCADE;

CREATE TABLE students (
    student_id      SERIAL PRIMARY KEY,
    student_number  VARCHAR(20)  NOT NULL UNIQUE,
    full_name       VARCHAR(100) NOT NULL
);

CREATE TABLE rooms (
    room_id      SERIAL PRIMARY KEY,
    room_number  VARCHAR(10) NOT NULL UNIQUE,
    capacity     INTEGER     NOT NULL CHECK (capacity > 0)
);

CREATE TABLE allocations (
    allocation_id  SERIAL PRIMARY KEY,
    student_id     INTEGER     NOT NULL REFERENCES students(student_id),
    room_id        INTEGER     NOT NULL REFERENCES rooms(room_id),
    allocated_on   DATE        NOT NULL,
    released_on    DATE,
    status         VARCHAR(10) NOT NULL,
    CONSTRAINT ck_status CHECK (status IN ('ACTIVE', 'ENDED')),
    -- ACTIVE needs NULL released_on; ENDED needs a release date
    CONSTRAINT ck_status_release CHECK (
        (status = 'ACTIVE' AND released_on IS NULL) OR
        (status = 'ENDED'  AND released_on IS NOT NULL)),
    CONSTRAINT ck_release_after_allocation CHECK (
        released_on IS NULL OR released_on >= allocated_on)
);

CREATE TABLE occupancy_snapshot (
    snapshot_date  DATE    NOT NULL,
    room_id        INTEGER NOT NULL REFERENCES rooms(room_id),
    occupied_beds  INTEGER NOT NULL CHECK (occupied_beds >= 0),
    free_beds      INTEGER NOT NULL CHECK (free_beds >= 0),
    PRIMARY KEY (snapshot_date, room_id)
);

INSERT INTO students (student_number, full_name) VALUES
    ('202405001', 'Mwape Chola'),
    ('202405002', 'Tendai Moyo'),
    ('202405003', 'Chipo Daka'),
    ('202405004', 'Lweendo Hachamba'),
    ('202405005', 'Bupe Kasonde');

INSERT INTO rooms (room_number, capacity) VALUES
    ('R101', 2),   -- will be full
    ('R102', 3),   -- will be partly occupied
    ('R103', 2);   -- will have no ACTIVE allocations
-- Allocations are loaded in 08_load_data.sql
