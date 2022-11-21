-- Hand
minetest.register_tool(":", {
    wield_image = "sotm_hand.png",
    wield_scale = {x=1,y=1.5,z=4},
    range = 3,
    groups = {not_in_creative_inventory = 1},
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 1,
        groupcaps = {
            oddly_breakable_by_hand = {
                maxlevel = 1,
                uses = 0,
                times = {1, 2, 4},
            },
        }
    },
})

minetest.register_on_joinplayer(function(player)
    -- Spacesuit texture
    player_api.set_textures(player, {"sotm_player.png"})

    player:hud_set_flags({
        minimap = true,
        minimap_radar = true,
    })

    player:set_properties({
       zoom_fov = 15,
       breath_max = 60000, -- 10 minutes of air outside the base
   })
end)

local spawn = vector.new(0, 63.5, 0)

minetest.register_on_joinplayer(function(player, last_login)
    if last_login ~= nil then return end

    player:set_pos(spawn)

    if minetest.get_modpath("sotm_tools") then
        player:get_inventory():add_item("main", "sotm_tools:jackhammer")
    end

    if minetest.get_modpath("sotm_nodes") then
        player:get_inventory():add_item("main", "sotm_nodes:worklight 5")
    end
end)

minetest.register_on_respawnplayer(function(player)
    player:set_pos(spawn)
end)
