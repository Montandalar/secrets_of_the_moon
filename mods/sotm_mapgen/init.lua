local CID_MOONSTONE = minetest.get_content_id("sotm_nodes:moonrock")

local function sotm_mapgen_underground(minp, maxp, blockseed, vm)
    local buf = vm:get_data()
    local nbuf = #buf
    for i=1,nbuf do
        buf[i] = CID_MOONSTONE
    end
    vm:set_data(buf)
    vm:write_to_map(true)

end

local function sotm_on_mapgen(minp, maxp, blockseed)
    local vm = minetest.get_mapgen_object("voxelmanip")
    if maxp.y > 256 then return end
    if minp.y < 0 then
        sotm_mapgen_underground(minp,maxp, blockseed, vm)
        return
    end

end

minetest.register_on_generated(sotm_on_mapgen)
