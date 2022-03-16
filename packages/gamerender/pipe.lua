local m = {}

function m.get_prototype_name(x, y, get_entity)
    local entity = get_entity(x, y)
    if not entity then
        log.error(("can not found entity(%s, %s)"):format(x, y))
        return
    end

    return "管道1-I型"
    -- return entity.prototype_name
end

return m