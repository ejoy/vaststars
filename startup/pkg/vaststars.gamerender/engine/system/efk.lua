local ecs = ...
local world = ecs.world
local w = world.w

local iefk = ecs.require "ant.efk|efk"
local eids = {}

local efk_sys = ecs.system "efk"
function efk_sys:final()
    for eid in pairs(eids) do
        local e = world:entity(eid, "efk?in light?in")
        if not iefk.is_playing(e) then
            world:remove_entity(eid)
            eids[eid] = nil
            print("efk removed", eid)
        end
    end
end

local m = {}
function m.play(f, srt)
    local eid; eid = world:create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.efk|efk",
        },
        data = {
            scene = srt or {},
            efk = {
                path = f,
                speed = 1.0,
            },
            visible_state = "main_queue",
            on_ready = function(e)
                w:extend(e, "efk?in light?in")
                iefk.play(e)

                print("efk created", eid)
                eids[eid] = true
            end
        },
    }
end

return m