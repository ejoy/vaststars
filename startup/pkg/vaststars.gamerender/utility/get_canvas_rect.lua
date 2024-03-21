local read_datalist = require "engine.datalist".read
local canvas_cfg = read_datalist "/pkg/vaststars.resources/textures/canvas.ant"

local function get_canvas_rect(name)
    local cfg = assert(canvas_cfg[name])
    return {x = cfg.x, y = cfg.y, w = cfg.width, h = cfg.height}
end
return get_canvas_rect