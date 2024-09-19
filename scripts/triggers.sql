--Оновити порядок зупинок у автобусному маршруті при вставці нового
CREATE OR REPLACE FUNCTION func_on_insert() RETURNS trigger
AS
$$
BEGIN
    UPDATE bus_routes_stops
    SET stop_order = stop_order + 1
    WHERE route_id = NEW.route_id
      AND stop_order >= NEW.stop_order;
    RAISE NOTICE 'Inserted new stop into bus route: id = %. Please, update the arrival_time value of the next stop.', NEW.route_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER shift_order_on_insert
    BEFORE INSERT
    ON bus_routes_stops
    FOR EACH ROW
EXECUTE FUNCTION func_on_insert();

INSERT INTO bus_routes_stops
VALUES (6, 96, 18, '00:01:00');

SELECT *
FROM bus_routes_stops
WHERE route_id = 6
ORDER BY route_id, stop_order;

--Оновити порядок зупинок у автобусному маршруті при видаленні
CREATE OR REPLACE FUNCTION func_on_delete() RETURNS trigger
AS
$$
BEGIN
    UPDATE bus_routes_stops
    SET stop_order = stop_order - 1
    WHERE route_id = OLD.route_id
      AND stop_order > OLD.stop_order;
    RAISE NOTICE 'Deleted a stop id: = % from bus route: id = %. Please, update the arrival_time value of the next stop.', OLD.stop_id, OLD.route_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER shift_order_on_delete
    BEFORE DELETE
    ON bus_routes_stops
    FOR EACH ROW
EXECUTE FUNCTION func_on_delete();

DELETE FROM bus_routes_stops
WHERE route_id = 6 AND stop_order = 18;

SELECT *
FROM bus_routes_stops
WHERE route_id = 6
ORDER BY route_id, stop_order;