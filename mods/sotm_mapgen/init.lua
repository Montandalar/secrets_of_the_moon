local CID_MOONSTONE = minetest.get_content_id("sotm_nodes:moonrock")
local CID_MOONSAND = minetest.get_content_id("sotm_nodes:moonsand")
local CID_MOONBASALT = minetest.get_content_id("sotm_nodes:moonbasalt")
local CID_MOONICE = minetest.get_content_id("sotm_nodes:moonice")

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

local function sotm_mapgen_base(minp, maxp, blockseed, vm)
    local path = minetest.get_modpath("sotm_mapgen") .. "/schems/moonbase.mts"
    local mt = minetest
    local mtrs = minetest.read_schematic
    print(dump(path))
    local base_schematic = minetest.read_schematic(path, {})
    print(dump(base_schematic))

    -- true = force
    local result = minetest.place_schematic(
        vector.new(0,63,0), base_schematic, "0", nil, true,
        { place_center_x = true, place_center_z = true, })

    minetest.set_node(vector.new(-1,64,4),
        {name="sotm_nodes:comms"})

    print(dump(result))
end

local function sotm_on_mapgen(minp, maxp, blockseed)
    local vm = minetest.get_mapgen_object("voxelmanip")
    if maxp.y > 256 then return end

    if is_inside(vector.new(0,0,0), minp, maxp) then
        sotm_mapgen_base(minp, maxp, blockseed, vm)
    end

    if minp.y < 0 then
        sotm_mapgen_underground(minp,maxp, blockseed, vm)
        return
    end

end

minetest.register_on_generated(sotm_on_mapgen)
