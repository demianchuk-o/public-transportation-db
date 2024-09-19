EXPLAIN ANALYSE SELECT * FROM metro_schedule WHERE day_id = 1 AND route_id = 1 AND interval_start BETWEEN '07:00:00' AND '19:00:00';

CREATE INDEX ms_index ON metro_schedule(row_id);
DROP INDEX ms_index;