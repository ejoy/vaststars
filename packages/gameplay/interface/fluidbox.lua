local prototype = require "prototype"

local function fluidId(name)
    local what = prototype.query("fluid", name)
    if what then
        return what.id
    end
    return 0
end

local function update(e, pt, fluids)
    assert(e.fluidboxes ~= nil)
    assert(#pt.fluidboxes.input <= 4)
    assert(#pt.fluidboxes.output <= 3)
    e.fluidbox_changed = true
    for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
        local what, i = classify:match "(%a*)(%d)"
        what = what.."put"
        i = tonumber(i)
        if fluids and fluids[what] and fluids[what][i] then
            local v = fluids[what][i]
            e.fluidboxes[classify.."_fluid"] = fluidId(v)
        else
            e.fluidboxes[classify.."_fluid"] = 0
        end
        e.fluidboxes[classify.."_id"] = 0
    end
end

return {
    update = update
}
