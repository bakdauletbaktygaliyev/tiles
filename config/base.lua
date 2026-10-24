---@diagnostic disable-next-line: undefined-global
local highways = osm2pgsql.define_table({
    name = 'highways',

    ids = { type = 'way', id_column = 'osm_id' },

    columns = {
        { column = 'highway', type = 'text' },
        { column = 'name',    type = 'text' },
        { column = 'geom',    type = 'linestring', projection = 3857 },
    }

})

---@diagnostic disable-next-line: undefined-global
local buildings = osm2pgsql.define_table({
    name = 'buildings',
    ids = { type = 'way', id_column = 'osm_id' },
    columns = {
        { column = 'name',     type = 'text' },
        { column = 'building', type = 'text' },
        { column = 'geom',     type = 'polygon', projection = 3857 },
    }
})

---@diagnostic disable-next-line: undefined-global
function osm2pgsql.process_way(object)
    local tags = object.tags
    if tags.highway then
        highways:insert({
            name = tags.name,
            highway = tags.highway,
            geom = object:as_linestring()
        })
    end

    if tags.building and object.is_closed then
        buildings:insert({
            name = tags.name,
            building = tags.building,
            geom = object:as_polygon()
        })
    end
end
