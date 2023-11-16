local m = {}

function m.pickup(world, item, amount)
    return false
end

function m.place(world, item, amount)
end

function m.query(world, item)
    return 0
end

function m.all(world)
    return {}
end

return m
