---@diagnostic disable-next-line: undefined-global
local highways = osm2pgsql.define_table({
    name = 'highways',

    ids = { type = 'way', id_column = 'osm_id' },

    columns = {
        { column = 'highway', type = 'text' },
        { column = 'name',    type = 'text' },
        { column = 'geom',    type = 'linestring', projection = 3857, not_null = true },
    }

})

---@diagnostic disable-next-line: undefined-global
local buildings = osm2pgsql.define_table({
    name = 'buildings',
    ids = { type = 'way', id_column = 'osm_id' },
    columns = {
        { column = 'name',     type = 'text' },
        { column = 'building', type = 'text' },
        { column = 'geom',     type = 'polygon', projection = 3857, not_null = true },
    }
})

---@diagnostic disable-next-line: undefined-global
local water = osm2pgsql.define_table({
    name = 'water',
    ids = { type = 'way', id_column = 'osm_id' },
    columns = {
        { column = 'name', type = 'text' },
        { column = 'kind', type = 'text' },
        { column = 'geom', type = 'polygon', projection = 3857, not_null = true },
    }
})

---@diagnostic disable-next-line: undefined-global
local landuse = osm2pgsql.define_table({
    name = 'landuse',
    ids = { type = 'way', id_column = 'osm_id' },
    columns = {
        { column = 'name', type = 'text' },
        { column = 'kind', type = 'text' },
        { column = 'geom', type = 'polygon', projection = 3857, not_null = true },
    }
})

---@diagnostic disable-next-line: undefined-global
local places = osm2pgsql.define_table({
    name = 'places',
    ids = { type = 'node', id_column = 'osm_id' },
    columns = {
        { column = 'name',       type = 'text' },
        { column = 'place',      type = 'text' },
        { column = 'population', type = 'text' },
        { column = 'geom',       type = 'point', projection = 3857, not_null = true }
    }
})

---@diagnostic disable-next-line: undefined-global
local boundaries = osm2pgsql.define_table({
    name = 'boundaries',
    ids = { type = 'relation', id_column = 'osm_id' },
    columns = {
        { column = 'name',        type = 'text' },
        { column = 'admin_level', type = 'int' },
        { column = 'geom',        type = 'multilinestring', projection = 3857, not_null = true }
    }
})

local function water_kind(tags)
    if tags.natural == 'water' then
        return tags.water or 'water'
    elseif tags.waterway == 'riverbank' then
        return 'riverbank'
    elseif tags.landuse == 'reservoir' or tags.landuse == 'basin' then
        return tags.landuse
    end

    return nil
end

local leisure_kinds = {
    park = true,
    garden = true,
    playground = true,
    pitch = true,
    golf_course = true,
    nature_reserve = true
}
local natural_kinds = {
    wood = true,
    scrub = true,
    grassland = true,
    wetland = true,
    heath = true,
    sand = true,
    bare_rock = true
}

local function landuse_kind(tags)
    local lu = tags.landuse

    if lu and lu ~= 'reservoir' and lu ~= 'basin' then
        return lu
    end
    if tags.leisure and leisure_kinds[tags.leisure] then
        return tags.leisure
    end
    if tags.natural and natural_kinds[tags.natural] then
        return tags.natural
    end

    return nil
end

local name_keys = {
    'name:kk', 'name:ru', 'name:en', 'name',
}

local function first_of(tags, keys)
    for _, v in ipairs(keys) do
        if tags[v] and tags[v] ~= '' then
            return tags[v]
        end
    end
end

---@diagnostic disable-next-line: undefined-global
function osm2pgsql.process_relation(object)
    local tags = object.tags
    if tags.type == 'boundary' and tags.boundary == 'administrative' then
        boundaries:insert({
            name = first_of(tags, name_keys),
            admin_level = tags.admin_level,
            geom = object:as_multilinestring()
        })
    end
end

---@diagnostic disable-next-line: undefined-global
function osm2pgsql.process_way(object)
    local tags = object.tags
    if tags.highway then
        highways:insert({
            name = first_of(tags, name_keys),
            highway = tags.highway,
            geom = object:as_linestring()
        })
    end

    if tags.building and object.is_closed then
        buildings:insert({
            name = first_of(tags, name_keys),
            building = tags.building,
            geom = object:as_polygon()
        })
    end

    local kind = water_kind(tags)
    if kind then
        water:insert({
            name = first_of(tags, name_keys),
            kind = kind,
            geom = object:as_polygon()
        })
    end

    kind = landuse_kind(tags)
    if kind then
        landuse:insert({
            name = first_of(tags, name_keys),
            kind = kind,
            geom = object:as_polygon()
        })
    end
end

---@diagnostic disable-next-line: undefined-global
function osm2pgsql.process_node(object)
    local tags = object.tags
    if tags.place then
        places:insert({
            name = first_of(tags, name_keys),
            place = tags.place,
            population = tags.population,
            geom = object:as_point()
        })
    end
end
