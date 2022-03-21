local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system 'debug_system'
local debug_mb = world:sub {"debug"}
local funcs = {}

funcs[1] = function ()
    local DIRECTION <const> = {
        [0] = 'N',
        [1] = 'E',
        [2] = 'S',
        [3] = 'W',
    }

    local gameplay = ecs.require "gameplay"
    import_package "vaststars.prototype"
    local gameplay_raw = import_package "vaststars.gameplay"

    local function get_prototype_name(prototype)
        local pt = gameplay_raw.query(prototype)
        if not pt then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return pt.name
    end

    local function get_slots(prototype)
        local pt = gameplay_raw.query(prototype)
        if not pt then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return pt.slots
    end

    local ecs = world.ecs
    for v in gameplay.select "entity:in chest?in" do
        print("dump -----------------", v.entity.x, v.entity.y, DIRECTION[v.entity.direction], get_prototype_name(v.entity.prototype))
        if v.chest then
            for i = 1, get_slots(v.entity.prototype) do
                local c, n = gameplay.container_get(v.chest.container, i)
                if c then
                    print(i, gameplay_raw.query(c).name, n)
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

