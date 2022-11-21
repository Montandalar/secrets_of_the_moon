sotm_nodes = {}

-- Natural Environment
minetest.register_node("sotm_nodes:vacuum", {
    description = "Vacuum",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    floodable = true,
    drowning = 1,
})

local sounds_stone = {
    footstep = { name = "sotm_stone", gain = 0.1 },
    dig = { name = "sotm_stone" },
    dug = { name = "sotm_stone" },
}

minetest.register_node("sotm_nodes:moonrock", {
    description = "Moon Rock",
    drawtype = "normal",
    tiles = {"sotm_moonrock.png"},
    groups = {cracky=1},
    sounds = sounds_stone,
    stack_max = "5",
})

minetest.register_node("sotm_nodes:moonbasalt", {
    description = "Moon Basalt",
    drawtype = "normal",
    tiles = {"sotm_moonbasalt.png"},
    groups = {cracky=1},
    sounds = sounds_stone,
    stack_max = "5",
})

minetest.register_node("sotm_nodes:moonsand", {
    description = "Moon Sand",
    drawtype = "normal",
    tiles = {"sotm_moonsand.png"},
    groups = {crumbly=1},
    sounds = {
        footstep = {name = "default_sand_footstep", gain = 0.05},
        dug = {name = "default_sand_footstep", gain = 0.15},
        place = {name = "default_place_node", gain = 1.0},
    },
    stack_max = "5",
})

minetest.register_node("sotm_nodes:moonice", {
    description = "Moon Ice",
    drawtype = "glasslike",
    paramtype1 = "light",
    paramtype2 = "none",
    tiles = {"sotm_moonice.png"},
    use_texture_alpha = "blend",
    sounds = {
        footstep = {name = "default_ice_footstep", gain = 0.15},
        dig = {name = "default_ice_dig", gain = 0.5},
        dug = {name = "default_ice_dug", gain = 0.5},
    },
    stack_max = "5",
})

-- Built environment
minetest.register_node("sotm_nodes:al2219", {
    description = "Aluminium Alloy 2219",
    drawtype = "normal",
    tiles = {"sotm_al2219.png"},
    sounds = {
        footstep = {name = "default_metal_footstep", gain = 0.2},
        dig = {name = "default_dig_metal", gain = 0.5},
        dug = {name = "default_dug_metal", gain = 0.5},
        place = {name = "default_place_node_metal", gain = 0.5},
    },
    groups = {metal=1, snappy=1},
    stack_max = "5",
})

minetest.register_node("sotm_nodes:porthole", {
    description = "Porthole",
    drawtype = "glasslike",
    tiles = {"sotm_porthole.png"},
    use_texture_alpha = "clip",
    sounds = {
        footstep =  {name = "default_glass_footstep", gain = 0.3},
        dig = {name = "default_glass_footstep", gain = 0.5},
        dug = {name = "default_break_glass", gain = 1.0},
    },
    groups = {cracky=1},
    stack_max = "5",
})

dofile(minetest.get_modpath("sotm_nodes") .. "/doors.lua")
dofile(minetest.get_modpath("sotm_nodes") .. "/collectors.lua")

minetest.register_node("sotm_nodes:comms", {
    description = "Comms Cabinet",
    paramtype = "light",
    light_source = 4,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5000, -0.5000, -0.5000, 0.5000, 0.2500, 0.2500}
        }
    },
    tiles = {
        "sotm_commscabinet.png^[sheet:4x1:1,0", --top
        "sotm_commscabinet.png^[sheet:4x1:1,0^[transformFY", --bottom
        "sotm_commscabinet.png^[sheet:4x1:2,0", -- right
        "sotm_commscabinet.png^[sheet:4x1:2,0^[transformFX", -- left
        "sotm_commscabinet.png^[sheet:4x1:3,0", -- back
        "sotm_commscabinet.png^[sheet:4x1:0,0", -- front
    },
    groups = {snappy=1},
    stack_max = "1",

    on_construct = function(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(5)
    end,

    -- Check for nearby collectors and win game if all types of collectors are
    -- filled within radius.
    on_timer = function(pos)
        --local found_filled_collectors = {}
        for nodename, _ in pairs(sotm_nodes.registered_collectors) do
            print(nodename)
            local pos = minetest.find_node_near(pos, 5, nodename)
            if not pos then print("Missing: ".. nodename) return true end

            local node = minetest.get_node(pos)
            local result = (node.param2 >= 50)
            if not result then print("Not filled:"..nodename) return true end
            --found_filled_collectors[nodename] = (node.param2 >= 50)
        end

        if minetest.get_modpath("sotm_story") then
            sotm_story.win_game()
        end
    end,
})

local worklight_box = {
	type = "fixed",
	fixed = {
		{-0.3750, -0.5000, 0.5000, 0.3750, -0.125, 0.1250}
	}
}

minetest.register_node("sotm_nodes:worklight", {
    description = "Work light",
    drawtype = "mesh",
    mesh = "sotm_worklight.obj",
    tiles = {"sotm_worklight.png"},
    groups = {metal=1, snappy=1, oddly_breakable_by_hand=1},
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = minetest.LIGHT_MAX,
    selection_box = worklight_box,
    collision_box = worklight_box,
    stack_max = "5",
})


-- TODO: sublimation of water
-- TODO: ladder, torch etc placement code to decide on vacuum or air surround in
-- on_place to avoid free air pockets

minetest.register_alias("mapgen_stone", "sotm_nodes:moonrock")

minetest.register_on_mods_loaded(function()
    sotm_tools.register_important_equipment("sotm_nodes:al2219")
    sotm_tools.register_important_equipment("sotm_nodes:comms")
end)
