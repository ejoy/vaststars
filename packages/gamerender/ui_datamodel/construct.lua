local fluid_category = require "gameplay.utility.get_fluid_category"()
local construct_menu = require "gameplay.utility.get_construct_menu"()

---------------
local M = {}

function M:create()
    return {
        fluid_category = fluid_category,
        construct_menu = construct_menu,
    }
end

function M:fps_text(datamodel, text)
    datamodel.fps_text = text
end

function M:drawcall_text(datamodel, text)
    datamodel.drawcall_text = text
end

return M