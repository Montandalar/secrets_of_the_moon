sotm_tools = { list = {} }
local tool_list = sotm_tools.list
local important_equipment = {}

function sotm_tools.register_important_equipment(nodename)
    important_equipment[nodename] = true
end

local function sound_play_denied(pos, player)
    minetest.sound_play("sotm_sfx_denied",
        {pos = pos, gain = 0.4, to_player = player})
end

minetest.register_tool("sotm_tools:jackhammer", {
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
                    minetest.registered_items[""].tool_capabilities or {}, nil)
            end
            return itemstack
        end

        local userpos = user:get_pos()
        local under_pos = pointed_thing.under
        local under_node = minetest.get_node(under_pos)
        local under_node_name = under_node.name
        print(minetest.settings:get("creative_mode"))
        if important_equipment[under_node_name] then
            if under_node_name:find("sotm_tools:charger_charged") then
                minetest.registered_nodes[under_node_name].on_punch(
                    under_pos, under_node, user, pointed_thing)
                return itemstack
            end

            local msg
            if under_node_name:find("sotm_tools:charger_charging") then
                msg = "Please wait patiently for your tool to charge, "
                    .."it will only take 2 seconds"
            else
                msg = "You can't remove that, it's important equipment!"
            end
            local username = user:get_player_name()
            minetest.chat_send_player(username, msg)
            sound_play_denied(userpos, username)
            return itemstack
        end

        local wear = itemstack:get_wear()
        local new_wear = wear+1000
        if new_wear >= 65535 then
            sound_play_denied(userpos, user:get_player_name())
            return itemstack
        end
        itemstack:set_wear(wear+1000)

        minetest.sound_play("sotm_jackhammer", {pos = userpos, gain = 0.3})

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

local charger_basedef = {
    paramtype = "light",
    paramtype2 = "wallmounted",
    light_source = 8,
    tiles = {"sotm_charger_base.png"},
    drawtype = "signlike",
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    groups = {metal=1, snappy=1, not_in_creative_inventory=1}
}

local empty_charger_def = table.copy(charger_basedef)
local function empty_charger_rightclick(pos, node, clicker, itemstack, pointed_thing)
    local itemstack_name = itemstack:get_name()
    local tool
    if itemstack_name == "" then -- hand
        minetest.chat_send_player(clicker:get_player_name(),
            "The charger is empty right now. You can put power tools like the "
           .. "jackhammer in it.")
        return itemstack
    end

    local toolname = itemstack_name:sub(itemstack_name:find(":")+1, -1)
    if not tool_list[toolname] then
        minetest.chat_send_player(clicker:get_player_name(),
            "That's not a tool you can charge with the tool charger.")
        return itemstack
    end

    -- Must be a tool
    local underpos = pointed_thing.under
    local charger_node = minetest.get_node(underpos)
    minetest.set_node(underpos,
        {name="sotm_tools:charger_charging_"..toolname,
        param1=charger_node.param1,
        param2=charger_node.param2})
    return ItemStack("")
end

for k, v in pairs({
    description = "Tool Charger",
    inventory_image = "sotm_charger_base.png",
    wield_image = "sotm_charger_base.png",
    on_rightclick = empty_charger_rightclick,
    groups = {metal=1, snappy=1}
}) do
    empty_charger_def[k] = v
end
minetest.register_node("sotm_tools:charger_empty", empty_charger_def)
important_equipment["sotm_tools:charger_empty"] = true

local function charging_on_punch(pos, node, puncher, pointed_thing)
    minetest.chat_send_player(puncher:get_player_name(),
        "Please wait patiently for your tool to charge, "
        .."it will only take 2 seconds"
    )
end

local function charging_on_rightclick(pos, node, clicker)
    minetest.chat_send_player(clicker:get_player_name(),
        "Your tool is still charging, please wait")
end

local function charging_on_construct(pos)
    minetest.sound_play("sotm_sfx_charging", {pos=pos, gain=0.5})
    minetest.get_node_timer(pos):start(2)
end

local function charging_on_timer(pos)
    local node = minetest.get_node(pos)
    local nodename = node.name
    local start, fin = nodename:find("charging_")
    assert(start ~= nil, "Charger could not convert to charged state @"
        .. tostring(pos) .. ": substring 'charging_' not found")
    local toolname = nodename:sub(fin+1,-1)
    minetest.set_node(pos,
        {name="sotm_tools:charger_charged_"..toolname,
        param1=node.param1,
        param2=node.param2})
end

local function charged_on_punch(pos, node, puncher, pointed_thing)
    local nodename = node.name
    local start, fin = nodename:find("charged_")
    assert(start ~= nil, "Charged could not pop out charged tool @"
        .. tostring(pos) .. ":substring 'charged_' not found")
    local toolname = nodename:sub(fin+1,-1)

    minetest.set_node(pos,
        {name="sotm_tools:charger_empty",
        param1=node.param1,
        param2=node.param2})
    minetest.add_item(pos, "sotm_tools:"..toolname)
end

-- Register a tool that can be charged with the charger
-- @arg toolname: string tool's name, to be appended to charger itemstring and
-- given back after charging.
-- @arg tool_texinfo: table {x:int offset, y:int offset, name: string texture
-- name}.
-- @arg exta_props: Any extra properties to be applied after the base definition
-- and the definitions of the charging and charged states.
function sotm_tools.register_charger_tool(toolname, tool_texinfo, extra_props)
    tool_list[toolname] = true

    local tool_overlay_tex = string.format("^[combine:%dx%d:%d,%d=%s",
        tool_texinfo.w, tool_texinfo.h,
        tool_texinfo.x, tool_texinfo.y,
        tool_texinfo.file)

    local charging_def = table.copy(charger_basedef)
    for k, v in pairs({
        on_punch = charging_on_punch,
        on_rightclick = charging_on_rightclick,
        on_construct = charging_on_construct,
        on_timer = charging_on_timer,
    }) do
        charging_def[k] = v
    end
    for k, v in pairs(extra_props or {}) do
        charging_def[k] = v
    end
    charging_def.tiles[1] = charging_def.tiles[1] .. tool_overlay_tex
        .. "^sotm_charger_indicator_inprogress.png"
        .. "^sotm_charger_plot_inprogress.png"
    local charging_node_name = "sotm_tools:charger_charging_"..toolname
    important_equipment[charging_node_name] = true
    minetest.register_node(charging_node_name, charging_def)

    local charged_def = table.copy(charger_basedef)
    for k, v in pairs({
        on_punch = charged_on_punch,
    }) do
        charged_def[k] = v
    end
    for k,v in pairs(extra_props or {}) do
        charged_def[k] = v
    end
    charged_def.tiles[1] = charged_def.tiles[1] .. tool_overlay_tex
        .. "^sotm_charger_indicator_done.png"
        .. "^sotm_charger_plot_done.png"
    local charged_node_name = "sotm_tools:charger_charged_" .. toolname
    important_equipment[charged_node_name] = true
    minetest.register_node(charged_node_name, charged_def)

end

sotm_tools.register_charger_tool("jackhammer", {
        w = 16, h = 16, x = 16, y = 13,
        file = "sotm_jackhammer.png",
})
