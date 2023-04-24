local iprototype = require "gameplay.interface.prototype"
local item_category = import_package "vaststars.prototype"("item_category")

return function ()
    local cache = {} -- item_index -> item
    local category_cache = {} -- category_index -> category
    local category_index_cache = {} -- item_id -> category_index
    local items_cache = {} -- category_index -> items

    do
        for _, typeobject in pairs(iprototype.each_type("item")) do
            -- "任务" is a special item that is not subject to any checks.
            if typeobject.name == "任务" then
                goto continue
            end

            -- If the 'pile' field is not configured, it is usually a 'building' that cannot be placed in a drone depot.
            if not typeobject.pile then
                goto continue
            end

            local item = {
                id = typeobject.id,
                name = typeobject.name,
                icon = typeobject.icon,
                category = assert(typeobject.group[1]),
                desc = typeobject.item_description,
            }

            cache[#cache+1] = item
            ::continue::
        end
    end

    do
        local category_name_to_index = {}
        category_cache = item_category

        for index, v in ipairs(category_cache) do
            category_name_to_index[v.category] = index
        end

        for _, item in pairs(cache) do
            category_index_cache[item.id] = assert(category_name_to_index[item.category])
        end
    end

    do
        for category_index, v in ipairs(category_cache) do
            local items = {}
            for _, item in pairs(cache) do
                if item.category == v.category or v.category == "全部" then
                    table.insert(items, item)
                end
            end
            table.sort(items, function(a, b)
                return a.name < b.name
            end)
            items_cache[category_index] = items
        end
    end

    return {
        cache = cache,
        category_cache = category_cache,
        category_index_cache = category_index_cache,
        items_cache = items_cache,
    }
end