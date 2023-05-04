require "item.init"
require "entity.init"
require "recipe"
require "technology"

local fs = require "filesystem"
local function loadCfg(filename)
    local fullpath = ("/pkg/vaststars.prototype/%s.lua"):format(filename)
    local res = setmetatable({}, {__index = _ENV})
    local f <close> = assert(fs.open(fs.path(fullpath), "r"))
	local cfg = assert(f:read [[*a]])
    assert(load(cfg, [[@]]..fs.path(fullpath):localpath():string(), [[t]], res))()
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
