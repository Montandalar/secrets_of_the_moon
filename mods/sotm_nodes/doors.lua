-- Doors

local node_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.375, 0.5, 0.5, -0.5}
	}
}

local node_box_open_left = {
    type = "fixed",
    fixed = {
        {-0.125, -0.5, -0.375, -0.5, 0.5, -0.5}
    }
}

local node_box_open_right = {
    type = "fixed",
    fixed = {
        {0.125, -0.5, -0.375, 0.5, 0.5, -0.5}
    }
}

local groups = {not_in_creative_inventory=1, snappy=1}

local function sound_open(pos)
    minetest.sound_play("sotm_sliding_door_open", {pos=pos, gain=0.6})
end

local function sound_close(pos)
    minetest.sound_play("sotm_sliding_door_close", {pos=pos, gain=0.1})
end

local function lookright(pos, param2)
    local adjacent
    if param2 == 0 then
        adjacent = vector.new(pos.x+1, pos.y, pos.z)
    elseif param2 == 1 then
        adjacent = vector.new(pos.x, pos.y, pos.z-1)
    elseif param2 == 2 then
        adjacent = vector.new(pos.x-1, pos.y, pos.z)
    elseif param2 == 3 then
        adjacent = vector.new(pos.x, pos.y, pos.z+1)
    end
    return adjacent
end

local function lookleft(pos, param2)
    local adjacent
    if param2 == 0 then
        adjacent = vector.new(pos.x-1, pos.y, pos.z)
    elseif param2 == 1 then
        adjacent = vector.new(pos.x, pos.y, pos.z+1)
    elseif param2 == 2 then
        adjacent = vector.new(pos.x+1, pos.y, pos.z)
    elseif param2 == 3 then
        adjacent = vector.new(pos.x, pos.y, pos.z-1)
    end
    return adjacent
end

-- Shut

minetest.register_node("sotm_nodes:sliding_door_left_bottom", {
    description = "Sliding Door",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:0,1", --top
        "sotm_airlock.png^[sheet:2x2:0,1", -- bottom
        "sotm_airlock.png^[sheet:2x2:0,1", --left
        "sotm_airlock.png^[sheet:2x2:0,1", -- right
        "sotm_airlock.png^[sheet:2x2:0,1^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:0,1", -- back
    },

    on_place = function (itemstack, user, pointed_thing)
        --print('bl place')
        local pos = vector.new(pointed_thing.under.x, pointed_thing.under.y+1,
            pointed_thing.under.z)
        local above_pos = vector.new(pos.x, pos.y+1, pos.z)
        local above_node = minetest.get_node(above_pos)
        local above_name = above_node.name

        local yaw = user:get_look_horizontal()
        local dir = minetest.yaw_to_dir(yaw)
        local facedir = minetest.dir_to_facedir(dir)

        if above_node.name ~= "air" then return end

        if not minetest.settings:get("creative_mode") then
            itemstack:take_item()
        end
        minetest.swap_node(pos, {
            name = "sotm_nodes:sliding_door_left_bottom",
            param2 = facedir,
        })

        minetest.add_node(vector.new(pos.x, pos.y+1, pos.z), {
            name="sotm_nodes:sliding_door_left_top",
            param2 = facedir})

        local adjacent = lookright(pos, facedir)
        local adjacent_above = vector.new(adjacent.x, adjacent.y+1, adjacent.z)

        if minetest.get_node(adjacent).name ~= "air" then return end
        if minetest.get_node(adjacent_above).name ~= "air" then return end
        minetest.add_node(adjacent, {
            name="sotm_nodes:sliding_door_right_bottom",
            param2=facedir})

        return itemstack
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        --print('bl shut rightclick')
        minetest.set_node(pos, {name="sotm_nodes:sliding_door_left_bottom_open", 
            param1=node.param1, param2=node.param2})
    end,

    on_destruct = function(pos)
        --print('bl shut destruct')
        local node = minetest.get_node(pos)
        local above_pos = vector.new(pos.x, pos.y+1, pos.z)
        local above_node = minetest.get_node(above_pos)
        local above_name = above_node.name
        if above_name == "sotm_nodes:sliding_door_left_top" then
            minetest.swap_node(above_pos, {name="air"})
        end

        local right_pos = lookright(pos, node.param2)
        local right_node = minetest.get_node(right_pos)
        local right_name = right_node.name
        if right_name == "sotm_nodes:sliding_door_right_bottom" then
            minetest.swap_node(right_pos, {name="air"})
        end

        local right_above_pos = vector.new(right_pos.x,
            right_pos.y+1, right_pos.z)
        local right_node = minetest.get_node(right_above_pos)
        local right_name = right_node.name
        if right_name == "sotm_nodes:sliding_door_right_top" then
            minetest.swap_node(right_above_pos, {name="air"})
        end

    end
})


-- FIXME: If opened from this node, never closes
minetest.register_node("sotm_nodes:sliding_door_left_top", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:0,0", --top
        "sotm_airlock.png^[sheet:2x2:0,0", -- bottom
        "sotm_airlock.png^[sheet:2x2:0,0", --left
        "sotm_airlock.png^[sheet:2x2:0,0", -- right
        "sotm_airlock.png^[sheet:2x2:0,0^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:0,0", -- back
    },

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        --print("tl shut rightclick")
        minetest.set_node(pos, {name="sotm_nodes:sliding_door_left_top_open",
            param1=node.param1, param2=node.param2})
    end,

    on_destruct = function(pos)
        --print('tl shut destruct')
        local below_pos = vector.new(pos.x, pos.y-1, pos.z)
        local below_node = minetest.get_node(below_pos)
        local below_name = below_node.name
        if below_node.name == "sotm_nodes:sliding_door_left_bottom" then
            minetest.swap_node(below_pos, {name="air"})
        end
    end,

    drop = "sotm_nodes:sliding_door_left_bottom",
})

minetest.register_node("sotm_nodes:sliding_door_right_bottom", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:1,1", --top
        "sotm_airlock.png^[sheet:2x2:1,1", -- bottom
        "sotm_airlock.png^[sheet:2x2:1,1", --left
        "sotm_airlock.png^[sheet:2x2:1,1", -- right
        "sotm_airlock.png^[sheet:2x2:1,1^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:1,1", -- back
    },
    drop = "sotm_nodes:sliding_door_left_bottom",
    
    on_construct = function(pos)
        local node = minetest.get_node(pos)
        local above = vector.new(pos.x, pos.y+1, pos.z)
        local above_node = minetest.get_node(above)
        if above_node.name ~= "air" then
            return
        end
        
        minetest.swap_node(above, {name="sotm_nodes:sliding_door_right_top",
            param1=node.param1, param2=node.param2})
    end
})

minetest.register_node("sotm_nodes:sliding_door_right_top", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:1,0", --top
        "sotm_airlock.png^[sheet:2x2:1,0", -- bottom
        "sotm_airlock.png^[sheet:2x2:1,0", --left
        "sotm_airlock.png^[sheet:2x2:1,0", -- right
        "sotm_airlock.png^[sheet:2x2:1,0^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:1,0", -- back
    },
    drop = "sotm_nodes:sliding_door_left_bottom",
})

-- Open

minetest.register_node("sotm_nodes:sliding_door_left_bottom_open", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box_open_left,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:0,1", --top
        "sotm_airlock.png^[sheet:2x2:0,1", -- bottom
        "sotm_airlock.png^[sheet:2x2:0,1", --left
        "sotm_airlock.png^[sheet:2x2:0,1", -- right
        "sotm_airlock.png^[sheet:2x2:0,1^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:0,1", -- back
    },
    drop = "sotm_nodes:sliding_door_left_bottom",

    on_construct = function(pos)
        local node = minetest.get_node(pos)
        --print('bl open construct')

        local above_pos = vector.new(pos.x, pos.y+1, pos.z)
        local above_node = minetest.get_node(above_pos)
        local above_name = above_node.name
        if above_name == "air" or
            above_name == "sotm_nodes:sliding_door_left_top"
        then
            minetest.set_node(above_pos, {
                name="sotm_nodes:sliding_door_left_top_open",
                param1=node.param1, param2=node.param2})
        end

        local right_pos = lookright(pos, node.param2)
        local right_node = minetest.get_node(right_pos)
        local right_name = right_node.name
        if right_name == "air" or
            right_name == "sotm_nodes:sliding_door_right_bottom"
        then
            minetest.set_node(right_pos, {
                name="sotm_nodes:sliding_door_right_bottom_open",
                param1=node.param1, param2=node.param2})
        end

        local above_right_pos = vector.new(right_pos.x, right_pos.y+1,
            right_pos.z)
        local above_right_node = minetest.get_node(above_right_pos)
        local above_right_name = above_right_node.name
        if above_right_name == "air" or
            above_right_name == "sotm_nodes:sliding_door_right_top"
        then
            minetest.set_node(above_right_pos, {
                name="sotm_nodes:sliding_door_right_top_open",
                param1=node.param1, param2=node.param2})
        end


        sound_open(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,

    on_timer = function(pos, elapsed)
        --print('bl open timer')
        sound_close(pos)
        local n = minetest.get_node(pos)

        local above_pos = vector.new(pos.x, pos.y+1, pos.z)
        local above_node = minetest.get_node(above_pos)
        local above_name = above_node.name
        if above_name == "sotm_nodes:sliding_door_left_top_open" then
            minetest.swap_node(above_pos, {
                name="sotm_nodes:sliding_door_left_top",
                param1=n.param1, param2=n.param2,
            })
        end

        local right_pos = lookright(pos, n.param2)
        local right_node = minetest.get_node(right_pos)
        local right_name = right_node.name
        if right_name == "sotm_nodes:sliding_door_right_bottom_open" then
            minetest.swap_node(right_pos, {
                name="sotm_nodes:sliding_door_right_bottom",
                param1=n.param1, param2=n.param2})
        end

        local right_above_pos = vector.new(right_pos.x, right_pos.y+1,
            right_pos.z)
        local right_above_node = minetest.get_node(right_above_pos)
        local right_above_name = right_above_node.name
        if right_above_name == "sotm_nodes:sliding_door_right_top_open" then
            minetest.swap_node(right_above_pos, {
                name="sotm_nodes:sliding_door_right_top",
                param1=n.param1, param2=n.param2})
        end

        minetest.swap_node(pos, {name="sotm_nodes:sliding_door_left_bottom",
            param1=n.param1, param2=n.param2})
    end,

    on_destruct = function(pos)
        --print('bl open destruct')
        local above_pos = vector.new(pos.x, pos.y+1, pos.z)
        local above_node = minetest.get_node(above_pos)
        local above_name = above_node.name
        if above_node.name == "sotm_nodes:sliding_door_left_top_open" then
            minetest.swap_node(above_pos, {name="air"})
        end
    end

})

-- FIXME: Never closes if below is destroyed, due to nodetimer being only on
-- bottom.
minetest.register_node("sotm_nodes:sliding_door_left_top_open", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box_open_left,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:0,0", --top
        "sotm_airlock.png^[sheet:2x2:0,0", -- bottom
        "sotm_airlock.png^[sheet:2x2:0,0", --left
        "sotm_airlock.png^[sheet:2x2:0,0", -- right
        "sotm_airlock.png^[sheet:2x2:0,0^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:0,0", -- back
    },
    drop = "sotm_nodes:sliding_door_left_bottom",

    on_construct = function(pos)
        --print('tl open construct')
        local node = minetest.get_node(pos)
        local below_pos = vector.new(pos.x, pos.y-1, pos.z)
        local below_node = minetest.get_node(below_pos)
        local below_name = below_node.name
        local below_below_name = 
            minetest.get_node(vector.new(pos.x, pos.y-2, pos.z)).name
        if below_name == "air" and below_below_name ~= "air" then
            --print("nooooaiiiirr")
            minetest.set_node(below_pos, {
                name="sotm_nodes:sliding_door_left_bottom_open",
                param1=node.param1, param2=node.param2})
        end

        local right_pos = lookright(pos, node.param2)
        local right_node = minetest.get_node(right_pos)
        local right_name = right_node.name
        if right_name == "air" or
            right_name == "sotm_nodes:sliding_door_right_top"
        then
            minetest.set_node(right_pos, {
                name="sotm_nodes:sliding_door_right_top_open",
                param1=node.param1, param2=node.param2})
        end

        local below_right_pos = vector.new(right_pos.x, right_pos.y-1,
            right_pos.z)
        local below_right_node = minetest.get_node(below_right_pos)
        local below_right_name = below_right_node.name
        if below_right_name == "air" or
            below_right_name == "sotm_nodes:sliding_door_right_bottom"
        then
            minetest.set_node(below_right_pos, {
                name="sotm_nodes:sliding_door_right_bottom_open",
                param1=node.param1, param2=node.param2})
        end

        
        sound_open(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,

    on_timer = function(pos, elapsed)
        --print('tl open timer')
        sound_close(pos)
        local n = minetest.get_node(pos)

        local below_pos = vector.new(pos.x, pos.y-1, pos.z)
        local below_node = minetest.get_node(below_pos)
        local below_name = below_node.name
        if below_name == "sotm_nodes:sliding_door_left_bottom_open" then
            minetest.swap_node(below_pos, {
                name="sotm_nodes:sliding_door_left_bottom",
                param1=n.param1, param2=n.param2})
        end

        local right_pos = lookright(pos, n.param2)
        local right_node = minetest.get_node(right_pos)
        local right_name = right_node.name
        if right_name == "sotm_nodes:sliding_door_right_top_open" then
            minetest.swap_node(right_pos, {
                name="sotm_nodes:sliding_door_right_top",
                param1=n.param1, param2=n.param2})
        end

        local right_below_pos = vector.new(right_pos.x, right_pos.y-1,
            right_pos.z)
        local right_below_node = minetest.get_node(right_below_pos)
        local right_below_name = right_below_node.name
        if right_below_name == "sotm_nodes:sliding_door_right_bottom_open" then
            minetest.swap_node(right_below_pos, {
                name="sotm_nodes:sliding_door_right_bottom",
                param1=n.param1, param2=n.param2
            })
        end

        minetest.swap_node(pos, {name="sotm_nodes:sliding_door_left_top",
            param1=n.param1, param2=n.param2})
    end,

    on_destruct = function(pos)
        --print('tl open destruct')
        local below_pos = vector.new(pos.x, pos.y-1, pos.z)
        local below_node = minetest.get_node(below_pos)
        local below_name = below_node.name
        if below_name == "sotm_nodes:sliding_door_left_bottom"
            or below_name == "sotm_nodes:sliding_door_left_bottom_open"
        then
            minetest.swap_node(below_pos, {name="air"})
        end
    end

})


minetest.register_node("sotm_nodes:sliding_door_right_top_open", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box_open_right,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:1,0", --top
        "sotm_airlock.png^[sheet:2x2:1,0", -- bottom
        "sotm_airlock.png^[sheet:2x2:1,0", --left
        "sotm_airlock.png^[sheet:2x2:1,0", -- right
        "sotm_airlock.png^[sheet:2x2:1,0^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:1,0", -- back
    },
    drop = "sotm_nodes:sliding_door_left_bottom",
})

minetest.register_node("sotm_nodes:sliding_door_right_bottom_open", {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = node_box_open_right,
    groups = groups,
    tiles = {
        "sotm_airlock.png^[sheet:2x2:1,1", --top
        "sotm_airlock.png^[sheet:2x2:1,1", -- bottom
        "sotm_airlock.png^[sheet:2x2:1,1", --left
        "sotm_airlock.png^[sheet:2x2:1,1", -- right
        "sotm_airlock.png^[sheet:2x2:1,1^[transformFX", -- front
        "sotm_airlock.png^[sheet:2x2:1,1", -- back
    },
    drop = "sotm_nodes:sliding_door_left_bottom",
})

minetest.register_on_mods_loaded(function()
    sotm_tools.register_important_equipment("sotm_nodes:sliding_door_left_bottom")
    sotm_tools.register_important_equipment("sotm_nodes:sliding_door_left_top")
    sotm_tools.register_important_equipment("sotm_nodes:sliding_door_right_bottom")
    sotm_tools.register_important_equipment("sotm_nodes:sliding_door_right_top")
end)
