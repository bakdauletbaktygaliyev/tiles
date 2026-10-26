SELECT
    name,
    round((ST_Area(ST_Transform(geom, 4326)::geography) / 1e6)::numeric, 2) as area_km2
FROM landuse
WHERE kind = 'park' and name IS NOT NULL
ORDER BY area_km2 DESC
LIMIT 10;
