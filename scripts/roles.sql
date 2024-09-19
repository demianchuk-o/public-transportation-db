CREATE ROLE db_admin PASSWORD '1234';
CREATE ROLE db_viewer PASSWORD '1234';
CREATE ROLE abg_route_editor PASSWORD '1234';
CREATE ROLE metro_route_editor PASSWORD '1234';
CREATE ROLE abg_schedule_editor PASSWORD '1234';
CREATE ROLE metro_schedule_editor PASSWORD '1234';
CREATE ROLE passenger;

GRANT ALL ON ALL TABLES IN SCHEMA public TO db_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO db_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_viewer;

GRANT ALL ON bus_routes, tram_routes, bus_routes_stops, tram_routes_stops TO abg_route_editor;
GRANT SELECT ON above_ground_stops, bus_first_last, bus_route_list, tram_first_last, tram_route_list TO abg_route_editor;

GRANT ALL ON metro_routes, metro_routes_stations TO metro_route_editor;
GRANT SELECT ON metro_stations, metro_first_last, metro_route_list TO metro_route_editor;

GRANT ALL ON bus_schedule, tram_schedule TO abg_schedule_editor;
GRANT SELECT ON bus_routes, tram_routes, bus_routes_stops, tram_routes_stops TO abg_schedule_editor;

GRANT ALL ON metro_schedule TO metro_schedule_editor;
GRANT SELECT ON metro_routes, metro_routes_stations TO metro_schedule_editor;

GRANT SELECT ON bus_routes, tram_routes,
    bus_route_list, tram_route_list, metro_route_list,
    bus_first_last, tram_first_last,
    bus_a_to_b, tram_a_to_b,
    bus_schedule, tram_schedule, metro_schedule
TO passenger;

GRANT EXECUTE ON FUNCTION display_bus_arrivals(integer, integer) TO passenger;
GRANT EXECUTE ON FUNCTION display_metro_arrivals(integer, integer) TO passenger;
