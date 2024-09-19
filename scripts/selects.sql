--Вивести автобусні маршрути з їх першими і останніми зупинками
CREATE OR REPLACE VIEW bus_first_last
AS
SELECT bus_routes.route_id   id,
       bus_routes.route_name route,
       ags1.stop_id          s1,
       ags1.stop_name        first_stop,
       ags2.stop_id          s2,
       ags2.stop_name        last_stop
FROM bus_routes
         JOIN above_ground_stops ags1 ON ags1.stop_id = (SELECT bus_routes_stops.stop_id
                                                         FROM bus_routes_stops
                                                         WHERE bus_routes_stops.route_id = bus_routes.route_id
                                                           AND stop_order = 1)
         JOIN above_ground_stops ags2 ON ags2.stop_id = (SELECT bus_routes_stops.stop_id
                                                         FROM bus_routes_stops
                                                         WHERE bus_routes_stops.route_id = bus_routes.route_id
                                                           AND stop_order = (SELECT COUNT(stop_id)
                                                                             FROM bus_routes_stops
                                                                             WHERE bus_routes_stops.route_id = bus_routes.route_id));

SELECT *
FROM bus_first_last;
SELECT *
FROM bus_first_last
WHERE first_stop = 'Symyrenka St';

--Вивести трамвайні маршрути з їх першими і останніми зупинками
CREATE OR REPLACE VIEW tram_first_last
AS
SELECT tram_routes.route_id      id,
       tram_routes.route_name AS route,
       ags1.stop_id              s1,
       ags1.stop_name            first_stop,
       ags2.stop_id              s2,
       ags2.stop_name            last_stop
FROM tram_routes
         JOIN above_ground_stops ags1 ON ags1.stop_id = (SELECT tram_routes_stops.stop_id
                                                         FROM tram_routes_stops
                                                         WHERE tram_routes_stops.route_id = tram_routes.route_id
                                                           AND stop_order = 1)
         JOIN above_ground_stops ags2 ON ags2.stop_id = (SELECT tram_routes_stops.stop_id
                                                         FROM tram_routes_stops
                                                         WHERE tram_routes_stops.route_id = tram_routes.route_id
                                                           AND stop_order = (SELECT COUNT(stop_id)
                                                                             FROM tram_routes_stops
                                                                             WHERE tram_routes_stops.route_id = tram_routes.route_id));

SELECT *
FROM tram_first_last;
SELECT *
FROM tram_first_last
WHERE last_stop = 'Kontraktova Square';

--Вивести лінії метро з їх першими і останніми станціями
CREATE OR REPLACE VIEW metro_first_last
AS
SELECT metro_routes.route_id      id,
       metro_routes.route_name AS route,
       ms1.station_id             s1,
       ms1.station_name        AS first_stop,
       ms2.station_id             s2,
       ms2.station_name        AS last_stop
FROM metro_routes
         JOIN metro_stations ms1 ON ms1.station_id = (SELECT metro_routes_stations.stop_id
                                                      FROM metro_routes_stations
                                                      WHERE metro_routes_stations.route_id = metro_routes.route_id
                                                        AND stop_order = 1)
         JOIN metro_stations ms2 ON ms2.station_id = (SELECT metro_routes_stations.stop_id
                                                      FROM metro_routes_stations
                                                      WHERE metro_routes_stations.route_id = metro_routes.route_id
                                                        AND stop_order = (SELECT COUNT(stop_id)
                                                                          FROM metro_routes_stations
                                                                          WHERE metro_routes_stations.route_id = metro_routes.route_id));

SELECT route, first_stop, last_stop
FROM metro_first_last;

SELECT mfl.id, mfl.route, mfl.first_stop, mfl.last_stop, ms.inclusiveness inclusive
FROM metro_first_last mfl
         JOIN metro_stations ms ON ms.station_id = mfl.s2;
--Вивести автобусні маршрути та кількість зупинок кожного
SELECT bus_routes.route_id AS n, bus_routes.route_name AS route, COUNT(brs.stop_order) AS stops_amount
FROM bus_routes
         JOIN bus_routes_stops brs ON bus_routes.route_id = brs.route_id
GROUP BY bus_routes.route_id
ORDER BY bus_routes.route_id;

--Вивести список зупинок певного трамвайного маршруту
CREATE OR REPLACE VIEW tram_route_list
AS
SELECT tr.route_id r_id, tram_routes_stops.stop_order AS n, ags.stop_name stop_name
FROM tram_routes_stops
         JOIN above_ground_stops ags ON tram_routes_stops.stop_id = ags.stop_id
         JOIN tram_routes tr ON tr.route_id = tram_routes_stops.route_id
ORDER BY r_id, n;

SELECT n, stop_name
FROM tram_route_list
WHERE r_id = 3;

--Вивести список зупинок певного автобусного маршруту
CREATE OR REPLACE VIEW bus_route_list
AS
SELECT br.route_id b_id, bus_routes_stops.stop_order n, ags.stop_name stop_name
FROM bus_routes_stops
         JOIN bus_routes br ON br.route_id = bus_routes_stops.route_id
         JOIN above_ground_stops ags ON ags.stop_id = bus_routes_stops.stop_id
ORDER BY b_id, n;

SELECT n, stop_name
FROM bus_route_list
WHERE b_id = 4;

--Вивести список зупинок певної лінії метро
CREATE OR REPLACE VIEW metro_route_list
AS
SELECT mr.route_id m_id, mrs.stop_order n, ms.station_name stop_name, ms.inclusiveness inclusive
FROM metro_routes_stations mrs
JOIN metro_routes mr ON mr.route_id = mrs.route_id
JOIN metro_stations ms ON ms.station_id = mrs.stop_id
ORDER BY m_id, n;

SELECT * FROM metro_route_list;
--Вивести усі автобусні маршрути, що проходять через певну зупинку
SELECT bus_routes_stops.route_id AS n, br.route_name
FROM bus_routes_stops
         JOIN bus_routes br ON bus_routes_stops.route_id = br.route_id
WHERE stop_id = 15;

--Вивести час першого прибуття на першу зупинку вказаного автобусного маршруту
SELECT bus_routes.work_start + bus_routes_stops.arrival_time::interval AS time_of_arrival
FROM bus_routes
         JOIN bus_routes_stops ON bus_routes.route_id = bus_routes_stops.route_id AND bus_routes_stops.stop_order = 1
WHERE bus_routes.route_id = 2;

--Вивести час першого прибуття на кінцеву зупинку трамвайних маршрутів
SELECT tr.route_name route, (tr.work_start + SUM(trs.arrival_time)) time_of_arrival
FROM tram_routes tr
         JOIN tram_routes_stops trs ON tr.route_id = trs.route_id AND stop_order = (SELECT COUNT(trs1.stop_order)
                                                                                    FROM tram_routes_stops trs1
                                                                                    WHERE trs1.route_id = tr.route_id)
GROUP BY tr.route_id;
--Вивести час першого прибуття на вказану зупинку вказаного автобусного маршруту

CREATE VIEW bus_nth_stop_first_arrival
AS
SELECT bus_routes.route_id                                 r_id,
       bus_routes.route_name                               r_name,
       brs1.stop_order                                     n_stop,
       (bus_routes.work_start + SUM(brs2.arrival_time)) AS time_of_arrival
FROM bus_routes
         JOIN bus_routes_stops brs1 ON brs1.route_id = bus_routes.route_id
         JOIN bus_routes_stops brs2 ON brs2.stop_order <= brs1.stop_order
GROUP BY r_id, n_stop;

SELECT r_name, n_stop, time_of_arrival
FROM bus_nth_stop_first_arrival
WHERE r_id = 2
  AND n_stop = 6;

--Вивести час першого прибуття на вказану зупинку вказаного трамвайного маршруту
CREATE VIEW tram_nth_stop_first_arrival
AS
SELECT tram_routes.route_id                                 r_id,
       tram_routes.route_name                               r_name,
       trs1.stop_order                                      n_stop,
       (tram_routes.work_start + SUM(trs2.arrival_time)) AS time_of_arrival
FROM tram_routes
         JOIN tram_routes_stops trs1 ON trs1.route_id = tram_routes.route_id
         JOIN tram_routes_stops trs2 ON trs2.stop_order <= trs1.stop_order
GROUP BY r_id, n_stop;

SELECT r_name, n_stop, time_of_arrival
FROM tram_nth_stop_first_arrival
WHERE r_id = 1
  AND n_stop = 3;

--Вивести час першого прибуття на вказану станцію вказаної лінії метро
CREATE VIEW metro_nth_stop_first_arrival
AS
SELECT metro_routes.route_id                                 r_id,
       metro_routes.route_name                               r_name,
       mrs1.stop_order                                       n_stop,
       (metro_routes.work_start + SUM(mrs2.arrival_time)) AS time_of_arrival
FROM metro_routes
         JOIN metro_routes_stations mrs1 ON mrs1.route_id = metro_routes.route_id
         JOIN metro_routes_stations mrs2 ON mrs2.stop_order <= mrs1.stop_order
GROUP BY r_id, n_stop;

SELECT r_name, n_stop, time_of_arrival
FROM metro_nth_stop_first_arrival
WHERE r_id = 2
  AND n_stop = 7;

--Вивести список ліній метро і інклюзивних зупинок на них
SELECT mrs.route_id, mr.route_name, ms.station_name, ms.inclusiveness
FROM metro_routes_stations mrs
         JOIN metro_routes mr ON mr.route_id = mrs.route_id
         JOIN metro_stations ms ON ms.station_id = mrs.stop_id
WHERE ms.inclusiveness = TRUE;

--Вивести список автобусних маршрутів, в яких можна потрапити з зупинки А на зупинку Б
CREATE VIEW bus_A_to_B
AS
SELECT br.route_id,
       br.route_name,
       brs1.stop_id   stop_1,
       ags1.stop_name A_name,
       brs2.stop_id   stop_2,
       ags2.stop_name B_name
FROM bus_routes br
         JOIN bus_routes_stops brs1 ON br.route_id = brs1.route_id
         JOIN bus_routes_stops brs2 ON br.route_id = brs2.route_id
         JOIN above_ground_stops ags1 ON ags1.stop_id = brs1.stop_id
         JOIN above_ground_stops ags2 ON ags2.stop_id = brs2.stop_id
WHERE brs1.stop_order < brs2.stop_order;

SELECT *
FROM bus_A_to_B
WHERE stop_1 = 10
  AND stop_2 = 15;

--Вивести список трамвайних маршрутів, в яких можна потрапити з зупинки А на зупинку Б
CREATE VIEW tram_A_to_B
AS
SELECT tr.route_id,
       tr.route_name,
       trs1.stop_id   stop_1,
       ags1.stop_name A_name,
       trs2.stop_id   stop_2,
       ags2.stop_name B_name
FROM tram_routes tr
         JOIN tram_routes_stops trs1 ON tr.route_id = trs1.route_id
         JOIN tram_routes_stops trs2 ON tr.route_id = trs2.route_id
         JOIN above_ground_stops ags1 ON ags1.stop_id = trs1.stop_id
         JOIN above_ground_stops ags2 ON ags2.stop_id = trs2.stop_id
WHERE trs1.stop_order < trs2.stop_order;
SELECT *
FROM tram_A_to_B;
--Вивести список автобусних і трамвайних маршрутів, в яких можна потрапити з зуп. А в зуп. Б
SELECT 'Автобус' transport, route_name, A_name, B_name
FROM bus_A_to_B
WHERE stop_1 = 16
  AND stop_2 = 17
UNION
SELECT 'Трамвай', route_name, A_name, B_name
FROM tram_A_to_B
WHERE stop_1 = 16
  AND stop_2 = 17;

--Вивести трамвайні маршрути та їх часову тривалість
SELECT trr.route_id, trr.route_name, CAST(SUM(trs.arrival_time) AS time) duration
FROM tram_routes trr
         JOIN tram_routes_stops trs ON trr.route_id = trs.route_id
GROUP BY trr.route_id, trr.route_name;

--Вивести наземні зупинки та кількість автобусних маршрутів, що через них проходять
CREATE OR REPLACE VIEW bus_stop_count
AS
SELECT ags.stop_id s_id, ags.stop_name, COUNT(brs.route_id) bus_routes
FROM above_ground_stops ags
         JOIN bus_routes_stops brs ON ags.stop_id = brs.stop_id
GROUP BY ags.stop_id, ags.stop_name
ORDER BY ags.stop_id;

SELECT *
FROM bus_stop_count;

--Вивести наземні зупинки та кількість трамвайних маршрутів, що через них проходять
CREATE OR REPLACE VIEW tram_stop_count
AS
SELECT ags.stop_id s_id, ags.stop_name, COUNT(trs.route_id) tram_routes
FROM above_ground_stops ags
         JOIN tram_routes_stops trs ON ags.stop_id = trs.stop_id
GROUP BY ags.stop_id, ags.stop_name
ORDER BY ags.stop_id;

SELECT *
FROM tram_stop_count;

--Вивести наземні зупинки та кількість автобусних і трамвайних маршрутів, що через них проходять
SELECT ags.stop_id,
       ags.stop_name,
       (COALESCE((SELECT tram_stop_count.tram_routes FROM tram_stop_count WHERE tram_stop_count.s_id = ags.stop_id),
                 0) +
        COALESCE((SELECT bus_stop_count.bus_routes FROM bus_stop_count WHERE bus_stop_count.s_id = ags.stop_id),
                 0)) total
FROM above_ground_stops ags
ORDER BY ags.stop_id;