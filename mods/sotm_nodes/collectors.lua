--[[minetest.register_node("sotm_nodes:collector_moonrock", { 
    description = "Moonrock Collection Bin",
    drawtype = "glasslike_framed_optional",
    paramtype2 = "glasslikeliquidlevel",
    tiles = {"sotm_collector.png"},
    use_texture_alpha = "blend",
    special_tiles = {"sotm_moonrock.png"},
})
--]]

function sotm_nodes.register_collector(base_node)
    local base_def = minetest.registered_nodes[base_node]
    local base_desc = base_def.description
    assert(base_def, "No such base node " .. base_node)
    assert(base_desc, "Base node needs a descrption:" .. base_node)

    local base_name = base_node:sub(base_node:find(":")+1, -1)
    local base_tex = base_def.tiles[1]
    local inv_cube_side = "(" .. base_tex .. "^sotm_collector.png)"
    local inv_image = minetest.inventorycube(inv_cube_side, 
        inv_cube_side, inv_cube_side)

    minetest.register_node("sotm_nodes:collector_"..base_name, {
        description = string.format("%s Collection Bin", base_desc),
        drawtype = "glasslike_framed_optional",
        paramtype = "light",
        paramtype2 = "glasslikeliquidlevel",
        tiles = {"sotm_collector.png"},
        inventory_image = inv_image,
        use_texture_alpha = "blend",
        special_tiles = {base_tex},
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            if itemstack:is_empty() then return end

            local pname = clicker:get_player_name()
            if itemstack:get_name() ~= base_node then
                minetest.chat_send_player(pname,
                    string.format("This collection bin is only for %s",
                        base_desc))
                return itemstack
            end

            -- We want to set the high bits to avoid connected glass appearance,
            -- but ignore them for capacity calculation.
            local p2_low = bit.band(63, node.param2)
            local p2_low = node.param2 + 1
            if p2_low > 50 then
                minetest.chat_send_player(pname,
                    "This collection bin is full, move onto another material")
                return itemstack
            end

            local result = itemstack:take_item(1)
            node.param2 = node.param2+1
            minetest.set_node(pos, {name=node.name, param1=node.param1,
                param2=node.param2})

            minetest.get_meta(pos):set_string("infotext", 
                string.format("%s collected: %d", base_desc, p2_low))

            return itemstack
        end,
    })
end

sotm_nodes.register_collector("sotm_nodes:moonrock")
sotm_nodes.register_collector("sotm_nodes:moonbasalt")
sotm_nodes.register_collector("sotm_nodes:moonsand")

minetest.register_on_mods_loaded(function()
    if minetest.get_modpath("sotm_tools") then
        sotm_tools.register_important_equipment("sotm_nodes:collector_moonrock")
    end
end)
