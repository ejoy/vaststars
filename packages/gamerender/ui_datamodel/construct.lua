local fluid_category = require "gameplay.utility.get_fluid_category"()
local construct_menu = require "gameplay.utility.get_construct_menu"()

local function create()
    return {
        fluid_category = fluid_category,
        construct_menu = construct_menu,
    }
end

local function update()
end

return {
    create = create,
    update = update,
}