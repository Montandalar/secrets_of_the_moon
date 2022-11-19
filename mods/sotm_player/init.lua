minetest.register_tool(":", {
    wield_image = "sotm_hand.png",
    wield_scale = {x=1,y=1.5,z=4},
	range = 3,
	groups = {not_in_creative_inventory = 1},
})

minetest.register_on_joinplayer(function(player)
    player_api.set_textures(player, {"sotm_player.png"})
end)
