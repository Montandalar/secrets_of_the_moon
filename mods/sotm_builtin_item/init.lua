local builtin_item_def = minetest.registered_entities["__builtin:item"]
local base_on_step = builtin_item_def.on_step

local function item_add(self, player)
    local itemstring = self.itemstring
    local player_inv = player:get_inventory()
    local remainder = player_inv:add_item("main", ItemStack(itemstring))
    minetest.sound_play("sotm_pickup", {pos=player:get_pos()})
    if remainder:to_string() ~= "" then
        self.itemstring = remainder:to_string()
    else
        self.object:remove()
    end
end

builtin_item_def.on_step = function(self, dtime, ...)
    local players = minetest.get_connected_players()
    for _, player in pairs(players) do
        local selfpos = self.object:get_pos()
        local playerpos = player:get_pos()
        local dist = vector.distance(selfpos, playerpos)
        if dist < 1 then
            item_add(self, player)
            return
        end
    end

	base_on_step(self, dtime, ...)
end

minetest.register_entity(":__builtin:item", builtin_item_def)
