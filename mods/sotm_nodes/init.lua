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
})

minetest.register_node("sotm_nodes:moonbasalt", {
    description = "Moon Basalt",
    drawtype = "normal",
    tiles = {"sotm_moonbasalt.png"},
    groups = {cracky=1},
    sounds = sounds_stone,
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
    }
})

-- Built environment
minetest.register_node("sotm_nodes:al2219", {
    description = "Aluminium Alloy 2219",
    drawtype = "normal",
    tiles = {"sotm_al2219.png"},
    groups = {metal=1, snappy=1},
})

minetest.register_node("sotm_nodes:porthole", {
    description = "Porthole",
    drawtype = "glasslike",
    tiles = {"sotm_porthole.png"},
    use_texture_alpha = "clip",
    groups = {cracky=1}
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
})


-- TODO: sublimation of water
-- TODO: ladder, torch etc placement code to decide on vacuum or air surround in
-- on_place to avoid free air pockets

minetest.register_alias("mapgen_stone", "sotm_nodes:moonrock")
