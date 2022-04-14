local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local debug_mb = world:sub {"debug"}
local funcs = {}

-- 删除地形
funcs[1] = function ()
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in id:in")
    if e then
       world:remove_entity(e.id)
    end
end

-- dump 所有箱子的物品
funcs[2] = function ()
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

