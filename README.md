# ICT371 Q5 - Hostel Room Allocation

**Student:** Steven Miti (202405283)  
**DBMS:** PostgreSQL 13+ with the pg_cron extension

## How to run
Use a fresh database for this question (several questions share table names such as `students`):

```bash
createdb ict371_q05
psql -d ict371_q05 -f run_all.sql
```

Files run in order: schema, function, procedure, trigger, view, index, scheduled job, data load, tests.
The data load (`08_load_data.sql`) runs after the trigger/procedure exist, as the question requires.

| Part | File |
|------|------|
| (a) Tables + seed data | `01_schema_seed.sql`, `08_load_data.sql` |
| (b) Function | `02_function.sql` |
| (c) Procedure | `03_procedure.sql` |
| (d) Trigger | `04_trigger.sql` |
| (e) View | `05_view.sql` |
| (f) Index + EXPLAIN | `06_index.sql` |
| (g) Scheduled job | `07_scheduled_job.sql` |
| Demonstration queries | `09_tests.sql` |

## Index
`idx_alloc_active_room ON allocations (room_id) WHERE status = 'ACTIVE' (partial index)`

Occupancy checks only ever look at ACTIVE allocations of one room. A partial index skips all ENDED history, so it stays small and the capacity check stays fast however much history builds up.

## Design notes
- Procedure and trigger both enforce the rules; the trigger excludes the row being updated when counting.
- uq_one_active_per_student (partial unique index) is a concurrency backstop for the one-ACTIVE-allocation rule.

## Output
_Paste screenshots / output of `09_tests.sql` and the `EXPLAIN` plan here._
