local aio = import_package "ant.io"
local datalist = require "datalist"
local function read_datalist(path)
    return datalist.parse(aio.readall(path))
end

local canvas_cfg = read_datalist "/pkg/vaststars.resources/textures/canvas.cfg"

local function get_canvas_rect(name)
    local cfg = assert(canvas_cfg[name])
    return {x = cfg.x, y = cfg.y, w = cfg.width, h = cfg.height}
end
return get_canvas_rect