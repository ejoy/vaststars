local type = require "register.type"

local STATUS_IN <const> = 0
local STATUS_OUT <const> = 1

local c = type "inserter"
    .speed "time"

function c:ctor(_, pt)
    return {
        inserter = {
            input_container = 0xFFFF,
            output_container = 0xFFFF,
            hold_item = 0,
            hold_amount = 0,
            progress = 0,
            status = STATUS_IN,
        }
    }
end

local function what_status(e)
    --TODO
    --  disabled
    --  no_minable_resources
    if e.capacitance.network == 0 then
        return "no_power"
    end
    local i = e.inserter
    if i.input_container == 0xFFFF or i.output_container == 0xFFFF then
        return "idle"
    end
    if i.progress <= 0 then
        if i.status == STATUS_IN then
            return "insufficient_input"
        elseif i.status == STATUS_OUT then
            return "full_output"
        end
    end
    if e.consumer.low_power ~= 0 then
        return "low_power"
    end
    return "working"
end
