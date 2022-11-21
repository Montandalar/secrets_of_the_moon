sotm_story = {}

-- Credit to Wuzzy for his Tutorial game's signs to make these formspecs

local function fs_broadcast(fs_name, formspec)
    for _,player in pairs(minetest.get_connected_players()) do
        minetest.show_formspec(player:get_player_name(), fs_name, formspec)
    end
end

function prepare_formspec(formspec_name, formspec, text)
    text = minetest.formspec_escape(text)
    text = text:gsub("\n", ",")

    formspec = formspec:format(formspec_name, text)
    return formspec
end

local formspec_preamble = [[size[12,12]
tablecolumns[text]
tableoptions[background=#000000dd;highlight=#00000000]
table[0,0;12,9;%s;%s;0]
button_exit[3,8;6,4;exeunt;Close]
]]

local intro_text = ([[
Welcome, newly trained Space Astronautical Geotechnical
Engineer (SAGE) to our agency's newest Lunar outpost.

You will recall that your role as a SAGE involves you
gathering samples from the Moon's outer crust that will
be returned to the central Lunar Laboratory for further
analysis.

We have identified that this region of the moon contains
four key classes of materials for our analysis. In simple
terms, this is Moon Rock, Moon Sand, Moon Basalt and
Moon Ice.

Your present mission is to retrieve 50 standard quantities
of each of these materials and return them to the material
collection bins provided in your outpost. You will use the
provided jackhammer to break up material for transport and
bring it back to this outpost. Return here any time you
run out of space to carry more samples or your jackhammer
is depleted. Do not worry about your space suit's oxygen
tanks running out, as you have been provided with enough
supply that you will not require a refill during your
mission.

Your transport back to the main laboratory should arrive
after you have gathered these samples. The communications
equipment beside your sample bins will identify when they
are full and dial for your pickup.

Good luck out there SAGE, and don't forget to have fun!

P.S. Due to budget shortfalls we have had to make some
cost savings in order to complete this outpost and deploy
your mission. Please note you will need to aim directly
for the button on the airlock doors to activate them,
and no vehicular transport is available until your pickup.
]])

function sotm_story.intro()
    fs_broadcast(
        "sotm_gamestart",
        prepare_formspec("sotm_gamestart", formspec_preamble, intro_text)
    )
end

local gameover_formspec = [[size[10.5,11]
table[0,0.25;12,5.2;gameover_text;Goodbye, world!] ]]

local gameover_text = [[
Excellent work in completing your mission, SAGE. The
specimens you have provided today will be crucial
to our analysis and understanding of the moon's
composition and history.

Please note your transport may not arrive promptly, but
you are free to sign off from your mission now.

--END OF GAME--
]]

function sotm_story.win_game()
    minetest.sound_play("sotm_gameover", {gain=0.6})
    fs_broadcast(
        "sotm_gameover",
        prepare_formspec("sotm_gameover", formspec_preamble, gameover_text)
    )
end


minetest.register_on_joinplayer(function(player)
    sotm_story.intro()
end)
