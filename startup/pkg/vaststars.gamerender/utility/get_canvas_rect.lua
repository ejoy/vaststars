local function read_datalist(path)
    local fs = require "filesystem"
    local datalist = require "datalist"
    local fastio = require "fastio"
    return datalist.parse(fastio.readall(fs.path(path):localpath():string(), path))
end
local canvas_cfg = read_datalist "/pkg/vaststars.resources/textures/canvas.cfg"

local function get_canvas_rect(name)
    local cfg = assert(canvas_cfg[name])
    return {x = cfg.x, y = cfg.y, w = cfg.width, h = cfg.height}
end
return get_canvas_rect