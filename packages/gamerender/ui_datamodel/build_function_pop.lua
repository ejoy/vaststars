local global = require "global"
local objects = global.objects
local cache_names = global.cache_names
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"

local function create(object_id, left, top)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype:queryByName("entity", object.prototype_name)

    -- 组装机才显示设置配方菜单
    local show_set_recipe = false
    local recipe_name = ""
    if iprototype:has_type(typeobject.type, "assembling") then
        assert(e.assembling)
        show_set_recipe = true

        if e.assembling.recipe ~= 0 then
            local typeobject = iprototype:query(e.assembling.recipe)
            if typeobject.ingredients ~= "" then -- 配方没有原料也不需要显示[设置配方]
                recipe_name = typeobject.name
            end
        end
    end

    return {
        show_set_recipe = show_set_recipe,
        recipe_name = recipe_name,
        object_id = object_id,
        left = ("%0.2fvmin"):format(math.max(left - 41.5, 0)),
        top = ("%0.2fvmin"):format(math.max(top - 30, 0)),
    }
end

local function update(datamodel, param, object_id, recipe_name)
    if param[1] ~= object_id then
        return
    end

    datamodel.recipe_name = recipe_name
    return true
end

return {
    create = create,
    update = update,
}