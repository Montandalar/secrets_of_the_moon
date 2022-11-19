local function set_player_physics(player)
    player:set_physics_override({
        gravity = 0.165,
    })
end

minetest.register_on_joinplayer(set_player_physics)
