local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local debug_mb = world:sub {"debug"}
local terrain = ecs.require "terrain"
local funcs = {}

-- 删除地形
funcs[1] = function ()
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in id:in")
    if e then
       world:remove_entity(e.id)
    end
end

funcs[2] = function ()
    terrain.create()
end

funcs[3] = function ()
    local gameplay_core = ecs.require "gameplay.core"
    import_package "vaststars.prototype"
    local gameplay = import_package "vaststars.gameplay"
    local general = require "gameplay.utility.general"
    local dir_tostring = general.dir_tostring

    local function get_prototype_name(prototype)
        local typeobject = gameplay.query(prototype)
        if not typeobject then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return typeobject.name
    end

    local function format_vars(fmt, tbl_vars)
        tbl_vars = tbl_vars or {}
        return (string.gsub(fmt, "%${([%w_]+)}", tbl_vars))
    end

    local function get_fluidbox_str(fluidbox)
        if not fluidbox then
            return ""
        end
        local typeobject = gameplay.query(fluidbox.fluid)
        return format_vars([[fluid = "${fluid}",]] , {fluid = typeobject.name})
    end

    local r = {}
    for e in gameplay_core.select "entity:in fluidbox?in fluidboxes?in" do
        local s = format_vars(
        [[
world:create_entity "${prototype}" {
    x = ${x},
    y = ${y},
    dir = '${dir}',
    ${fluid}
}
        ]],
        {
            prototype = get_prototype_name(e.entity.prototype),
            x = e.entity.x,
            y = e.entity.y,
            dir = dir_tostring(e.entity.direction),
            fluid = get_fluidbox_str(e.fluidbox)
        })
        r[#r+1]= s
    end
    print(table.concat(r, "\n"))
end

-- dump 所有箱子的物品
funcs[4] = function ()
    local DIRECTION <const> = {
        [0] = 'N',
        [1] = 'E',
        [2] = 'S',
        [3] = 'W',
    }

    local gameplay_core = ecs.require "gameplay.core"
    import_package "vaststars.prototype"
    local gameplay = import_package "vaststars.gameplay"

    local function get_prototype_name(prototype)
        local typeobject = gameplay.query(prototype)
        if not typeobject then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return typeobject.name
    end

    local function get_slots(prototype)
        local typeobject = gameplay.query(prototype)
        if not typeobject then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return typeobject.slots
    end

    for v in gameplay_core.select "entity:in chest?in" do
        print("dump -----------------", v.entity.x, v.entity.y, DIRECTION[v.entity.direction], get_prototype_name(v.entity.prototype))
        if v.chest then
            for i = 1, get_slots(v.entity.prototype) do
                local c, n = gameplay_core.container_get(v.chest.container, i)
                if c then
                    print(i, gameplay.query(c).name, n)
                else
                    break
                end
            end
        end
    end
end

function debug_sys:ui_update()
    for _, i in debug_mb:unpack() do
        local func = funcs[i]
        if func then
            func()
        end
    end
end

