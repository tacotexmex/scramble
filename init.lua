scramble = {}

scramble.hash = function(name)
    return "0x" .. string.sub(minetest.sha1(name), 1, 8)
end

scramble.is_hashed = function(name)
    local is_hashed = false
    for name,_ in pairs(minetest.registered_nodes) do
        if string.sub(name,1,2, "0x") then
            is_hashed = true
        end
    end
    return is_hashed
end

scramble.unhash = function(hashed_name)
    local unhashed_name
    for alias, original_name in pairs(minetest.registered_aliases) do
        if hashed_name == original_name then
            if string.find(alias, ":") then
                unhashed_name = dump(alias)
            end
        end
    end
    return unhashed_name
end

minetest.register_on_mods_loaded(function()
    local nodes = table.copy(minetest.registered_nodes)
    local aliases = table.copy(minetest.registered_aliases)
    for name, def in pairs(nodes) do
        -- print(tostring(def.liquidtype))
        if name ~= "ignore" and name ~= "air" and def.liquidtype ~= "source" then
            minetest.unregister_item(name)
            minetest.register_node(":" .. scramble.hash(name), def)
            minetest.register_alias(name, scramble.hash(name))
            -- print("Scrambling: " .. name .. " -> " .. scramble.hash(name))
        end
        for alias, original_name in pairs(aliases) do
            if alias ~= "ignore" and alias ~= "air" and original_name ~= "" and (nodes[original_name] and nodes[original_name].liquidtype and nodes[original_name].liquidtype ~= "source") then
                -- print("Alias before: " .. alias .. " -> " .. original_name)
                minetest.registered_aliases[alias] = nil
                minetest.register_alias(alias, scramble.hash(original_name))
                -- print("Alias after : " .. alias .. " -> " .. minetest.registered_aliases[alias])
            end
        end
    end
end)
