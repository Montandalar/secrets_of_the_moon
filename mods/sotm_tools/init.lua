minetest.register_node("sotm_tools:jackhammer", {
    description = "Jackhammer",
    drawtype = "plantlike",
    tiles = {"sotm_jackhammer.png"},
    inventory_image = "sotm_jackhammer.png",
    wield_image = "sotm_jackhammer.png^[transformR270",

    stack_max = 1,
    groups = {tool=1},
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 1,
        groupcaps = {
            cracky = {times = {2.50, 1.40, 1.00}, uses = 20, maxlevel = 2}
        }
    },
    on_use = function(itemstack, user, pointed_thing)
        if not pointed_thing or pointed_thing.type ~= "node" then
            if pointed_thing.type == "object" then
                -- Pass through to entity's on_punch
                pointed_thing.ref:punch(user, 0,
                    minetest.registered_items[""].tool_capabilities, nil)
            end
            return itemstack
        end

        local userpos = user:get_pos()
        local wear = itemstack:get_wear()
        local new_wear = wear+1000
        if new_wear >= 65535 then
            minetest.sound_play("sotm_sfx_denied", {pos = userpos, gain = 0.4})
            return itemstack
        end
        itemstack:set_wear(wear+1000)

        minetest.sound_play("sotm_jackhammer", {pos = userpos, gain = 0.3})

        local under_pos = pointed_thing.under
        local under_node = minetest.get_node(under_pos)
        minetest.dig_node(pointed_thing.under)
        for i=1,16 do
            minetest.add_particle({
                pos = vector.new(
                    under_pos.x + ((math.random()*0.5)-0.25),
                    under_pos.y + ((math.random()*0.5)-0.25),
                    under_pos.z + ((math.random()*0.5)-0.25)
                ),
                velocity = vector.new(
                    (math.random() - 0.5) * 3,
                    math.random()*3,
                    (math.random() - 0.5) * 3
                ),
                acceleration = vector.new(
                    0,
                    -1 * user:get_physics_override().gravity,
                    0
                ),
                texture = minetest.registered_nodes[under_node.name].tiles[1],
            })
        end
        return itemstack

    end,
})
