local serialize = import_package "ant.serialize"
local canvas_cfg = serialize.load "/pkg/vaststars.resources/textures/canvas.ant"

local function get_canvas_rect(name)
    local cfg = assert(canvas_cfg[name])
    return {x = cfg.x, y = cfg.y, w = cfg.width, h = cfg.height}
end
return get_canvas_rect