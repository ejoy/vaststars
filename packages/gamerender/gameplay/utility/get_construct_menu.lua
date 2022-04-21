local gameplay = import_package "vaststars.gameplay"
local config = import_package "vaststars.config"
local construct_menu = config.construct_menu

local function get_entity_icon(prototype_name)
    local typeobject = gameplay.queryByName("entity", prototype_name)
    if not typeobject then
        log.err(("can not found entity `%s`"):format(prototype_name))
        return ""
    end
    return typeobject.icon
end

local get; do
    local t = {}

    for _, menu in ipairs(construct_menu) do
        local m = {}
        m.name = menu.name
        m.image = menu.image
        m.detail = {}

        for _, prototype_name in ipairs(menu.detail) do
            local d = {}
            d.prototype = prototype_name
            d.icon = get_entity_icon(prototype_name)

            m.detail[#m.detail + 1] = d
        end

        t[#t+1] = m
    end

    function get()
        return t
    end
end

return get