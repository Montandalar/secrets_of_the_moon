minetest.register_node("sotm_nodes:moonrock", {
    drawtype = "normal",
    tiles = {"sotm_moonrock.png"},
    groups = {cracky=1},
    sounds = {
        dig = { name = "sotm_stone" },
        dug = { name = "sotm_stone" },
    },
})

minetest.register_node("sotm_nodes:vacuum", {
    drawtype = "airlike",
    description = "Vacuum",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    floodable = true,
})

-- TODO: sublimation of water
-- TODO: ladder, torch etc placement code to decide on vacuum or air surround in
-- on_place to avoid free air pockets

minetest.register_alias("mapgen_stone", "sotm_nodes:moonrock")
