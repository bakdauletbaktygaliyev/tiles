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
function osm2pgsql.process_way(object)
    if object.tags.highway then
        highways:insert({
            name = object.tags.name,
            highway = object.tags.highway,
            geom = object:as_linestring(),
        })
    end
end
