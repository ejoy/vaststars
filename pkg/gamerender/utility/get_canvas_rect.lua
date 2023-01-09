local fs = require "filesystem"
local datalist = require "datalist"
local canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/canvas.cfg")):read "a")

local function get_canvas_rect(name)
    local cfg = assert(canvas_cfg[name])
    return {x = cfg.x, y = cfg.y, w = cfg.width, h = cfg.height}
end
return get_canvas_rect