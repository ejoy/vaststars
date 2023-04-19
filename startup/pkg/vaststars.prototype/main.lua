require "item.init"
require "entity.init"
require "recipe"
require "technology"

local fs = require "filesystem"
local function loadCfg(filename)
    local res = {}
    local f <close> = assert(fs.open(fs.path(("/pkg/vaststars.prototype/%s.lua"):format(filename)), "r"))
	local cfg = assert(f:read [[*a]])
    assert(load(cfg, [[@]]..filename, [[t]], res))()
    return res
end

return setmetatable({
    load = loadCfg,
},
{
    __call = function(_, f)
        return require(f)
    end,
})
