local num_fertilizer_nodes = 10
local cycle_time = 3 * 60
local variation = 1 * 60

for i=1,num_fertilizer_nodes do
    local name = "fertilepots:fertilizer_" .. i
    local next_name = (i ~= num_fertilizer_nodes) and ("fertilepots:fertilizer_" .. (i + 1)) or "air"
    minetest.register_node(name, {
        description = "Fertilizer",
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {
                {-0.5, -0.5, -0.5, 0.5, 0.5 - (0.1 * (i - 1)), 0.5},
            },
        },
        tiles = {"default_dirt.png^[colorize:#333:127"},
        sounds = default.node_sound_dirt_defaults(),

        groups = {fertilizer = 1, not_in_creative_inventory = (i == 1) and 0 or 1, crumbly = 3},
        drop = (i == 1) and "fertilepots:fertilizer_1" or "",

        _doc_items_longdesc = "Decays into nearby Absorbing Pots.",
        _doc_items_create_entry = (i == 1),

        on_construct = function(pos)
            minetest.get_node_timer(pos):start(math.max(1, math.random(cycle_time - variation / 2, cycle_time + variation / 2) / num_fertilizer_nodes))
        end,

        on_timer = function(pos)
            minetest.set_node(pos, {name = next_name})

            if math.random() < 0.2 then
                local empty = {}
                local flora = {}

                for x=-1,1 do
                for z=-1,1 do
                    local check = vector.add(pos, vector.new(x, 0, z))
                    local above = vector.add(check, vector.new(0, 1, 0))

                    if minetest.get_item_group(minetest.get_node(check).name, "flora_pot") > 0 then
                        if minetest.get_item_group(minetest.get_node(above).name, "flora") > 0 then
                            table.insert(flora, above)
                        elseif minetest.get_node(above).name == "air" and (minetest.get_node_light(above) or 0) >= 10 then
                            table.insert(empty, above)
                        end
                    end
                end
                end

                if #flora > 0 and #empty > 0 then
                    minetest.set_node(empty[math.random(#empty)], {
                        name = minetest.get_node(flora[math.random(#flora)]).name})
                end
            end
        end,
    })

    if i ~= 1 and minetest.get_modpath("doc") then
        doc.add_entry_alias("nodes", "fertilepots:fertilizer_1", "nodes", name)
    end
end

minetest.register_craft{
    output = "fertilepots:fertilizer_1",
    recipe = {
        {"group:sapling", "", "group:sapling"},
        {"", "group:soil", ""},
        {"group:sapling", "", "group:sapling"},
    },
}

minetest.register_craft{
    output = "fertilepots:fertilizer_1",
    recipe = {
        {"group:leaves", "group:leaves", "group:leaves"},
        {"group:leaves", "group:soil", "group:leaves"},
        {"group:leaves", "group:leaves", "group:leaves"},
    },
}

minetest.register_node("fertilepots:pot", {
    description = "Fertilizer Absorbing Pot",
    _doc_items_longdesc = "When placed on the same vertical level as fertilizer, flora on a pot may spread to another pot adjacent to the same fertilizer.",
    sounds = default.node_sound_dirt_defaults(),
    groups = {flora_pot = 1, cracky = 3, oddly_breakable_by_hand = 3},
    tiles = {
        "default_dirt.png",
        "default_brick.png",
        "default_brick.png",
        "default_brick.png",
        "default_brick.png",
        "default_brick.png",
    },
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
            {-0.35, -0.5, -0.35, 0.35, 0, 0.35},
        },
    },
})

minetest.register_craft{
    output = "fertilepots:pot",
    recipe = {
        {"default:brick", "group:soil", "default:brick"},
        {"default:brick", "group:soil", "default:brick"},
        {"", "default:brick", ""},
    },
}
