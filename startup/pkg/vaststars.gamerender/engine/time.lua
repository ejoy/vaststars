local ltask = require "ltask"
local ltask_now = ltask.now

local function now()
    local _, t = ltask_now() --10ms
    return t * 10
end

return {
    now = now,
}
