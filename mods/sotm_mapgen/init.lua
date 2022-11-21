sotm_spawn = vector.new(0,0,0)
local CID_MOONSTONE = minetest.get_content_id("sotm_nodes:moonrock")
local CID_MOONSAND = minetest.get_content_id("sotm_nodes:moonsand")
local CID_MOONBASALT = minetest.get_content_id("sotm_nodes:moonbasalt")
local CID_MOONICE = minetest.get_content_id("sotm_nodes:moonice")

minetest.register_alias("mapgen_stone", "sotm_nodes:moonrock")
minetest.register_alias("mapgen_water_source", "sotm_nodes:moonice")
minetest.register_alias("mapgen_lava_source", "sotm_nodes:moonice")
minetest.register_alias("mapgen_dirt", "sotm_nodes:moonrock")
minetest.register_alias("mapgen_dirt_with_grass", "sotm_nodes:moonrock")
minetest.register_alias("mapgen_sand", "sotm_nodes:moonsand")

minetest.register_alias("mapgen_tree", "air")
minetest.register_alias("mapgen_leaves", "air")
minetest.register_alias("mapgen_apple", "air")

minetest.register_biome({
    name = "mare",
    node_stone = "sotm_nodes:moonbasalt",
    heat_point = 75,
    humidity_point = 25,
})

minetest.register_biome({
    name = "highlands",
    node_stone = "sotm_nodes:moonrock",
    node_top = "sotm_nodes:moonsand",
    heat_point = 25,
    humidity_point = 75,
})

minetest.register_biome({
    name = "degraded_highlands",
    node_stone = "sotm_nodes:moonsand",
    heat_point = 25,
    humidity_point = 25,
})

minetest.register_biome({
    name = "ice",
    node_stone = "sotm_nodes:moonrock",
    heat_point = 25,
    humidity_point = 75,
})

minetest.register_ore({
    ore_type = "blob",
    ore = "sotm_nodes:moonice",
    wherein = {"sotm_nodes:moonrock"},
    clust_scarcity = 20*20*20,
    clust_size = 5,
    y_max = 32,
    y_min = -50,
    noise_threshold = 0.0,

    noise_params = {
        offset = 0.5,
        scale = 0.5,
        spread = {x = 3, y = 3, z = 3},
        seed = 6615,
        octaves = 1,
        persist = 0.0,
    }
})

local function is_inside(pos, minp, maxp)
    local result
    result =            (pos.x > minp.x)
    result = result and (pos.x < maxp.x)
    result = result and (pos.y > minp.y)
    result = result and (pos.y < maxp.y)
    result = result and (pos.z > minp.z)
    result = result and (pos.z < maxp.z)
    return result
end

local function sotm_mapgen_underground(minp, maxp, blockseed, vm)
    local buf = vm:get_data()
    local nbuf = #buf

    for i=1,nbuf do
        buf[i] = CID_MOONSTONE
    end

    vm:set_data(buf)
    vm:write_to_map(true)

end

-- https://dev.minetest.net/Spawn_Algorithm
local function find_spawn()
    local range = 1
    local result
    local y
    local x
    local z
    repeat
        if range >= 4000 then
            return vector.new(0,0,0)
        end
        x = math.random(-range, range)
        z = math.random(-range, range)
        y = minetest.get_spawn_level(x, z)
        range = range+1
    until y ~= nil
    return vector.new(x, y-3, z)
end

local function sotm_mapgen_base(minp, maxp, blockseed, vm)
    local path = minetest.get_modpath("sotm_mapgen") .. "/schems/moonbase.mts"
    local mt = minetest
    local mtrs = minetest.read_schematic
    local base_schematic = minetest.read_schematic(path, {})

    sotm_spawn = find_spawn()
    assert(sotm_spawn, "Couldn't find a spawn, sorry!")

    -- true = force
    local result = minetest.place_schematic(
        sotm_spawn, base_schematic, "0", nil, true,
        { place_center_x = true, place_center_z = true, })

    minetest.set_node(vector.new(sotm_spawn.x-1, sotm_spawn.y+1, sotm_spawn.z+4),
        {name="sotm_nodes:comms", param2=3})

    for idx, ply in pairs(minetest.get_connected_players()) do
        ply:set_pos(vector.new(sotm_spawn.x, sotm_spawn.y+0.5, sotm_spawn.z))
    end


end

local function sotm_on_mapgen(minp, maxp, blockseed)
    local vm = minetest.get_mapgen_object("voxelmanip")
    if maxp.y > 256 then return end

    --[[if minp.y < 0 then
        sotm_mapgen_underground(minp,maxp, blockseed, vm)
        return
    end--]]

    local set = minetest.get_mapgen_setting_noiseparams("mgv5_np_ground")
end

minetest.register_on_generated(sotm_on_mapgen)

minetest.after(1, function()
    if minetest.get_gametime() < 10 then
        minetest.after(1, function()
            minetest.emerge_area(vector.new(0, 0, 0), vector.new(0,128,0))
        end
        )

        minetest.after(5, sotm_mapgen_base)
    end
end)
