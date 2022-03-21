local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system 'debug_system'
local debug_mb = world:sub {"debug"}
local funcs = {}

funcs[1] = function ()
    local gameplay = ecs.require "gameplay"
    import_package "vaststars.prototype"
    local gameplay_raw = import_package "vaststars.gameplay"

    local function get_slots(prototype)
        local pt = gameplay_raw.query(prototype)
        if not pt then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return pt.slots
    end

    local ecs = world.ecs
    for v in gameplay.select "chest:in entity:in" do
        print("dump -----------------", v.entity.x, v.entity.y, v.entity.dir)
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

function debug_sys:ui_update()
    for _, i in debug_mb:unpack() do 
        local func = funcs[i]
        if func then
            func()
        end
    end
end

