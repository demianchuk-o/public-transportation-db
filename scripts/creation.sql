DROP TABLE IF EXISTS bus_routes_stops;
DROP TABLE IF EXISTS tram_routes_stops;
DROP TABLE IF EXISTS metro_routes_stations;
DROP TABLE IF EXISTS bus_schedule;
DROP TABLE IF EXISTS tram_schedule;
DROP TABLE IF EXISTS metro_schedule;
DROP TABLE IF EXISTS bus_routes;
DROP TABLE IF EXISTS tram_routes;
DROP TABLE IF EXISTS metro_routes;
DROP TABLE IF EXISTS above_ground_stops;
DROP TABLE IF EXISTS metro_stations;
DROP TABLE IF EXISTS days_of_week;

CREATE TABLE days_of_week
(
    day_id   smallint,
    day_name varchar(10) NOT NULL UNIQUE,
    PRIMARY KEY (day_id)
);

CREATE TABLE above_ground_stops
(
    stop_id       smallserial,
    stop_name     varchar(50) NOT NULL UNIQUE,
    PRIMARY KEY (stop_id)
);

CREATE TABLE metro_stations
(
    station_id      smallserial,
    station_name    varchar(30) NOT NULL UNIQUE,
    inclusiveness   BOOLEAN,
    PRIMARY KEY (station_id)
);

CREATE TABLE bus_routes
(
    route_id   smallserial,
    route_name varchar(4),
    work_start time NOT NULL,
    work_end   time NOT NULL,
    PRIMARY KEY (route_id),
    CONSTRAINT bus_time_check CHECK (work_start < work_end)
);

CREATE TABLE tram_routes
(
    route_id   smallserial,
    route_name varchar(3),
    work_start time NOT NULL,
    work_end   time NOT NULL,
    PRIMARY KEY (route_id),
    CONSTRAINT tram_time_check CHECK (work_start < work_end)
);

CREATE TABLE metro_routes
(
    route_id   smallserial,
    route_name varchar(2),
    work_start time NOT NULL,
    work_end   time NOT NULL,
    PRIMARY KEY (route_id),
    CONSTRAINT metro_time_check CHECK (work_start < work_end)
);

CREATE TABLE bus_schedule
(
    row_id   smallserial,
    day_id   smallint,
    route_id smallint,
    interval_start time NOT NULL,
    interval_end time NOT NULL,
    interval time NOT NULL,
    PRIMARY KEY (row_id),
    FOREIGN KEY (day_id) REFERENCES days_of_week (day_id) ON DELETE NO ACTION,
    FOREIGN KEY (route_id) REFERENCES bus_routes (route_id) ON DELETE CASCADE
);

CREATE TABLE tram_schedule
(
    row_id   smallserial,
    day_id   smallint,
    route_id smallint,
    interval_start time NOT NULL,
    interval_end time NOT NULL,
    interval time NOT NULL,
    PRIMARY KEY (row_id),
    FOREIGN KEY (day_id) REFERENCES days_of_week (day_id) ON DELETE NO ACTION,
    FOREIGN KEY (route_id) REFERENCES tram_routes (route_id) ON DELETE CASCADE
);

CREATE TABLE metro_schedule
(
    row_id   smallserial,
    day_id   smallint,
    route_id smallint,
    interval_start time NOT NULL,
    interval_end time NOT NULL,
    interval time NOT NULL,
    PRIMARY KEY (row_id),
    FOREIGN KEY (day_id) REFERENCES days_of_week (day_id) ON DELETE NO ACTION,
    FOREIGN KEY (route_id) REFERENCES metro_routes (route_id) ON DELETE CASCADE
);

CREATE TABLE bus_routes_stops(
    route_id smallint,
    stop_id smallint,
    stop_order smallint NOT NULL,
    arrival_time time NOT NULL,
    FOREIGN KEY (route_id) REFERENCES bus_routes(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES above_ground_stops(stop_id) ON DELETE CASCADE
);

CREATE TABLE tram_routes_stops(
    route_id smallint,
    stop_id smallint,
    stop_order smallint NOT NULL,
    arrival_time time NOT NULL,
    FOREIGN KEY (route_id) REFERENCES tram_routes(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES above_ground_stops(stop_id) ON DELETE CASCADE
);

CREATE TABLE metro_routes_stations(
    route_id smallint,
    stop_id smallint,
    stop_order smallint NOT NULL,
    arrival_time time NOT NULL,
    FOREIGN KEY (route_id) REFERENCES metro_routes(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES metro_stations(station_id) ON DELETE CASCADE
);