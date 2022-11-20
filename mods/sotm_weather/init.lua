local function setup_sky(player)
    player:set_sky({
        type = "plain",
        clouds = false,
        textures = {},
        base_color = {"black"}
    })

    player:set_sun({
        visible = true,
        texture = "sotm_sun.png",
        sunrise_visible = false,
    })

    -- Actually Earth
    player:set_moon({
        visible = true,
        texture = "sotm_earth.png",
        scale = 3,
    })

    player:set_stars({
        visible = true,
        day_opacity = 0.4,
    })
end

minetest.register_on_joinplayer(setup_sky)
