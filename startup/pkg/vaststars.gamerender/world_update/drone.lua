local ecs = ...
local world = ecs.world
local w = world.w
local math3d    = require "math3d"
local mc = import_package "ant.math".constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local objects = require "objects"
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local gameplay_core = require "gameplay.core"
local entity_remove = world:sub {"gameplay", "remove_entity"}
local sampler_group
local function create_motion_object(s, r, t, parent)
    if not sampler_group then
        sampler_group = ims.sampler_group()
        sampler_group:enable "view_visible"
        sampler_group:enable "scene_update"
    end
    return sampler_group:create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.motion_sampler|motion_sampler",
            "ant.general|name",
        },
        data = {
            scene = {
                parent = parent,
                s = s,
                r = r,
                t = t,
            },
            name = "motion_sampler",
        }
    }
end

local drone_depot = {}
local lookup_drones = {}
local drone_offset = 6
local fly_height = 20
local item_height = 15
local function create_drone(homepos)
    local task = {
        stage = 0,--{0,1,2}
        running = false,
        elapsed_time = 0,
        start_duration = 0,
        end_duration = 0,
        duration = 0,
        at_home = false,
        gohome = function (self, dst)
            if self.at_home then
                return
            end
            self.at_home = true
            self:flyto(fly_height, dst, 1.0, true)
        end,
        flyto = function (self, height, to, duration, home)
            if not home then
                self.at_home = false
            end
            self.duration = duration
            self.start_duration = duration * 0.25
            self.end_duration = duration * 0.25
            self.end_y = {to = {0, to[2], 0}, tin = mc.TWEEN_QUARTIC, tout = mc.TWEEN_QUARTIC}
            --
            self:moveto(self.motion_xz, {to[1], 0, to[3]}, duration, mc.TWEEN_SINE, mc.TWEEN_SINE)
            self:moveto(self.motion_y, {0, height, 0}, self.start_duration, mc.TWEEN_QUARTIC, mc.TWEEN_QUARTIC)
            self.running = true
        end,
        moveto = function (self, motion, topos, time, tin, tout)
            local e <close> = w:entity(motion)
            if self.born_pos then
                ims.set_target_ex(e, {t = math3d.vector(self.born_pos)}, {t = math3d.vector(topos)}, time * 1000, tin, tout)
                self.born_pos = nil
            else
                ims.set_target(e, nil, nil, math3d.vector(topos), time * 1000, tin, tout)
            end
        end,
        update = function (self, timeStep)
            if not self.running then
                return
            end
            self.elapsed_time = self.elapsed_time + timeStep
            if self.stage == 0 then
                if self.elapsed_time >= self.start_duration then
                    self.stage = 1
                end
            elseif self.stage == 1 then
                if self.elapsed_time >= self.duration - self.end_duration then
                    self.stage = 2
                    local y = self.end_y
                    self:moveto(self.motion_y, y.to, self.end_duration, y.tin, y.tout)
                end
            else
                local endtime = self.duration
                -- if not self.reverse then
                --     endtime = endtime + 0.2
                -- end
                if self.elapsed_time >= endtime then
                    self.running = false
                    self.elapsed_time = 0
                    self.stage = 0
                    if self.item then
                        for _, eid in ipairs(self.item.tag["*"]) do
                            w:remove(eid)
                        end
                        self.item = nil
                        -- TODO: update dest item count
                        if self.target and drone_depot[self.target.gameplay_eid] then
                            drone_depot[self.target.gameplay_eid]:update_heap(1)
                            -- print("--------targetobj", self.target.gameplay_eid)
                        end
                    end
                end
            end
        end,
        destroy = function (self)
            for _, eid in ipairs(self.prefab.tag["*"]) do
                w:remove(eid)
            end
            w:remove(self.motion_y)
            w:remove(self.motion_xz)
        end,
        init = function (self, pos)
            if self.inited then
                return
            end
            self.inited = true
            self.born_pos = pos
            local ey <close> = w:entity(self.motion_y)
            iom.set_position(ey, math3d.vector(pos[1], 0, pos[3]))
            local exz <close> = w:entity(self.motion_xz)
            iom.set_position(exz, math3d.vector(0, pos[2], 0))
        end
    }
    local motion_xz = create_motion_object(nil, nil, math3d.vector(homepos[1], 0, homepos[3]))
    task.motion_xz = motion_xz
    local motion_y = create_motion_object(nil, nil, math3d.vector(0, homepos[2], 0), motion_xz)
    task.motion_y = motion_y
    task.prefab = sampler_group:create_instance("/pkg/vaststars.resources/prefabs/drone.prefab", motion_y)
    return task
end

local function get_object(lacation)
    return objects:coord(((lacation >> 23) & 0x1FF) // 2, ((lacation >> 14) & 0x1FF) // 2)
end

local function create_item(item, parent)
    local prefab = sampler_group:create_instance("/pkg/vaststars.resources/prefabs/rock.prefab", parent)
    prefab.on_init = function(inst) end
    prefab.on_ready = function(inst)
        local e <close> = w:entity(inst.tag["*"][1])
        iom.set_position(e, math3d.vector{0, -2.0, 0})
    end
    prefab.on_message = function(inst, ...) end
    world:create_object(prefab)
    return prefab
end

local function get_home_pos(pos)
    return {pos[1] + 6, pos[2] + 8, pos[3] - 6}
end

return function(gameworld)
    for _, _, geid in entity_remove:unpack() do
        -- local e = gameplay_core.get_entity(geid)
        -- if e.hub and drone_depot[geid] then
        --     drone_depot[geid]:destroy()
        --     drone_depot[geid] = nil
        -- end
    end

    local t = {}
    --TODO: update framerate is 30
    local elapsed_time = 1.0 / 30
    local same_dest_offset = {}
    local drone_task = {}
    for e in gameworld.ecs:select "drone:in eid:in" do
        local drone = e.drone
        assert(drone.prev ~= 0, "drone.prev == 0")
        -- if (drone.prev ~= 0) or (drone.next ~= 0) or (drone.maxprogress ~= 0) or (drone.progress ~= 0) then
        --     print(drone.prev, drone.next, drone.maxprogress, drone.progress, drone.item)
        -- end
        if not lookup_drones[e.eid] then
            local obj = get_object(drone.prev)
            assert(obj)
            lookup_drones[e.eid] = create_drone(get_home_pos(obj.srt.t))
        else
            local current = lookup_drones[e.eid]
            if not current.running then
                if drone.maxprogress > 0 then
                    if not current.start_progress then
                        current.start_progress = drone.progress
                    else
                        local stepCount = drone.maxprogress / (current.start_progress - drone.progress)
                        local total = stepCount * elapsed_time
                        local duration = (current.start_progress / drone.maxprogress) * total
                        current.start_progress = nil

                        local destobj = get_object(drone.next)
                        if destobj then
                            current.target = destobj
                            if drone.item > 0 then
                                current.item = create_item(drone.item, current.prefab.tag["*"][1])
                            end
                            -- TODO: update src item count
                            local srcobj = get_object(drone.prev)
                            if srcobj then
                                current:init(srcobj.srt.t)
                            end

                            local key = drone.prev << 32 | drone.next
                            if not same_dest_offset[key] then
                                same_dest_offset[key] = 0
                            else
                                same_dest_offset[key] = same_dest_offset[key] - (drone_offset / 2)
                            end
                            local dest_pos = destobj.srt.t
                            -- status : go_home
                            local tohome
                            if drone.status == 7 then
                                dest_pos = get_home_pos(dest_pos)
                                tohome = true
                            end
                            drone_task[#drone_task + 1] = {key, current, dest_pos, duration, tohome}
                        end
                    end
                elseif drone.status == 3 or drone.status == 4 then
                    -- status : at_home
                    local obj = get_object(drone.prev)
                    assert(obj)
                    current:gohome(get_home_pos(obj.srt.t))
                end
            else
                current:update(elapsed_time)
            end
        end
    end
    for _, task in ipairs(drone_task) do
        local key = task[1]
        local pos = task[3]
        task[2]:flyto(fly_height, {pos[1] + same_dest_offset[key], item_height, pos[3]}, task[4], task[5])
        same_dest_offset[key] = same_dest_offset[key] + drone_offset
    end
    return t
end