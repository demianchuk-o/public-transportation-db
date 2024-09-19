--Вивести години прибуття вказаного автобусного маршруту на вказану зупинку
CREATE OR REPLACE FUNCTION display_bus_arrivals(IN br_id integer, IN st_id integer)
    RETURNS TABLE
            (
                arrival time
            )
AS
$$
DECLARE
    st_ord       smallint;
    intr         interval;
    arr_time     time;
    w_end        time;
    time_of_week smallint;
BEGIN
    IF NOT EXISTS(SELECT stop_order FROM bus_routes_stops WHERE route_id = br_id AND stop_id = st_id) THEN
        RAISE NOTICE 'Input data is incorrect!';
    END IF;

    IF EXTRACT(DOW FROM CURRENT_DATE) BETWEEN 0 AND 4 THEN
        SELECT 1 INTO time_of_week;
    ELSE
        SELECT 2 INTO time_of_week;
    END IF;

    DROP TABLE IF EXISTS bus_arrivals;
    CREATE TEMP TABLE bus_arrivals
    (
        arrival time
    );

    SELECT stop_order FROM bus_routes_stops WHERE route_id = br_id AND stop_id = st_id INTO st_ord;
    SELECT time_of_arrival::time FROM bus_nth_stop_first_arrival WHERE r_id = br_id AND n_stop = st_ord INTO arr_time;
    SELECT bus_routes.work_end FROM bus_routes WHERE route_id = br_id INTO w_end;
    SELECT bus_schedule.interval::interval FROM bus_schedule WHERE route_id = br_id AND day_id = time_of_week INTO intr;
    WHILE arr_time < w_end
        LOOP
            INSERT INTO bus_arrivals(arrival) VALUES (arr_time);
            arr_time := arr_time + intr;
        END LOOP;

    RETURN QUERY (SELECT * FROM bus_arrivals);
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM display_bus_arrivals(1, 15);

--Вивести години прибуття на вказану станцію певної лінії метро
CREATE OR REPLACE FUNCTION display_metro_arrivals(IN mr_id integer, IN st_id integer)
    RETURNS TABLE
            (
                arrival time
            )
AS
$$
DECLARE
    st_ord       smallint;
    intr         interval;
    intr_end     time;
    w_end        time;
    arr_time     time;
    time_of_week smallint;
    cur CURSOR FOR SELECT ms.interval_end, ms.interval
                   FROM metro_schedule ms
                   WHERE route_id = mr_id
                     AND day_id = time_of_week;
BEGIN
    IF NOT EXISTS(SELECT stop_order FROM metro_routes_stations WHERE route_id = mr_id AND stop_id = st_id) THEN
        RAISE NOTICE 'Input data is incorrect!';
    END IF;

    IF EXTRACT(DOW FROM CURRENT_DATE) BETWEEN 0 AND 4 THEN
        SELECT 1 INTO time_of_week;
    ELSE
        SELECT 2 INTO time_of_week;
    END IF;

    DROP TABLE IF EXISTS metro_arrivals;
    CREATE TEMP TABLE metro_arrivals
    (
        arrival time
    );

    SELECT stop_order FROM metro_routes_stations WHERE route_id = mr_id AND stop_id = st_id INTO st_ord;
    SELECT time_of_arrival::time FROM metro_nth_stop_first_arrival WHERE r_id = mr_id AND n_stop = st_ord INTO arr_time;
    SELECT metro_routes.work_end FROM metro_routes WHERE route_id = mr_id INTO w_end;
    OPEN cur;
    FETCH cur INTO intr_end, intr;
    WHILE intr_end < w_end
        LOOP
            WHILE arr_time <= intr_end
                LOOP
                    INSERT INTO metro_arrivals(arrival) VALUES (arr_time);
                    arr_time := arr_time + intr;
                END LOOP;
            FETCH cur INTO intr_end, intr;
        END LOOP;
    CLOSE cur;
    RETURN QUERY (SELECT * FROM metro_arrivals);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM display_metro_arrivals(1, 4);