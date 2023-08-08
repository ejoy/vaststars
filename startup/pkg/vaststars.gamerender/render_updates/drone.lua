local ecs = ...
local world = ecs.world
local w = world.w
local math3d    = require "math3d"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local objects = require "objects"
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local iprototype = require "gameplay.interface.prototype"
local ltween = require "motion.tween"
local imotion = ecs.require "imotion"
local drone_sys = ecs.system "drone_system"
local gameplay_core = require "gameplay.core"
local global = require "global"
local terrain = ecs.require "terrain"
local irl = ecs.import.interface "ant.render|irender_layer"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

-- enum defined in c 
local STATUS_HAS_ERROR = 1
local BERTH_HUB = 0
local BERTH_RED = 1
local BERTH_BLUE = 2
local BERTH_HOME = 3
local drone_depot = {}
local lookup_drones = {}
local drone_offset = 6
local default_fly_height = 20
local fly_to_home_height = 15
local item_height = 15
local function create_drone(homepos)
    local task = {
        running = false,
        duration = 0,
        elapsed = 0,
        to_home = false,
        process = 0,
        flyid = 0,
        gohome = function (self, flyid, from, to, fly_height, duration)
            -- fix move drone hub
            -- if self.to_home then return end
            self:destroy_item()
            self:flyto(flyid, fly_height, from, to, true, duration or 30)
            self.to_home = true
        end,
        flyto = function (self, flyid, height, from, to, home, duration, start)
            self.flyid = flyid
            if self.to_home and not home then
                local exz <close> = w:entity(self.motion_xz)
                local xzpos = iom.get_position(exz)
                local ey <close> = w:entity(self.motion_y)
                local xpos = iom.get_position(ey)
                from = math3d.vector {math3d.index(xzpos, 1), math3d.index(xpos, 2), math3d.index(xzpos, 3)}
                self.to_home = false
            end
            local exz <close> = w:entity(self.motion_xz)
            ims.set_tween(exz, ltween.type("Sine"), ltween.type("Sine"))
            ims.set_keyframes(exz,
                {t = math3d.set_index(from, 2, 0), step = 0.0},
                {t = math3d.set_index(to, 2, 0),  step = 1.0}
            )
            local ey <close> = w:entity(self.motion_y)
            ims.set_tween(ey, ltween.type("Quartic"), ltween.type("Quartic"))
            ims.set_keyframes(ey,
                {t = math3d.vector({0, math3d.index(from, 2), 0}), step = 0.0},
                {t = math3d.vector({0, height, 0}), step = 0.1},
                {t = math3d.vector({0, height, 0}), step = 0.9},
                {t = math3d.vector({0, math3d.index(to, 2), 0}),  step = 1.0}
            )
            ims.set_duration(exz, duration, start or 0, true)
            ims.set_duration(ey, duration, start or 0, true)
            self.running = true
        end,
        update = function (self, step, hasitem)
            if not self.running then
                return
            end
            local finished = false
            if self.to_home then
                --TODO: framerate is 30
                local elapsed = 1--1.0 / 30
                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= self.duration then
                    finished = true
                end
            else
                if step >= 1.0 then
                    finished = true
                end
            end
            if finished then
                self.running = false
                self.elapsed = 0
            end
            if not hasitem then
                self:destroy_item()
            end
        end,
        set_item = function (self, item)
            self:destroy_item()
            self.item = item
        end,
        destroy_item = function (self)
            if not self.item then
                return
            end
            for _, eid in ipairs(self.item.tag["*"]) do
                w:remove(eid)
            end
            self.item = nil
        end,
        destroy = function (self)
            self:destroy_item()
            for _, eid in ipairs(self.prefab.tag["*"]) do
                w:remove(eid)
            end
            w:remove(self.motion_y)
            w:remove(self.motion_xz)
        end,
    }
    task.current_pos = homepos
    local motion_xz = imotion.create_motion_object(nil, nil, math3d.set_index(homepos, 2, 0))
    task.motion_xz = motion_xz
    local motion_y = imotion.create_motion_object(nil, nil, math3d.vector(0, math3d.index(homepos, 2), 0), motion_xz)
    task.motion_y = motion_y
    task.prefab = imotion.sampler_group:create_instance("/pkg/vaststars.resources/prefabs/drone.prefab", motion_y)
    task.prefab.on_ready = function(self)
        for _, eid in ipairs(self.tag["*"]) do
            local e <close> = w:entity(eid, "render_object?update")
            if e.render_object then
                irl.set_layer(e, RENDER_LAYER.DRONE)
            end
        end
    end
    world:create_object(task.prefab)

    return task
end

local function get_berth(lacation)
    return (lacation >> 5) & 0x03
end

local function get_home_pos(pos)
    return math3d.add(math3d.set_index(pos, 2, 0), {6, 8, -6})
end

local function remove_drone(eid)
    if lookup_drones[eid] then
        lookup_drones[eid]:destroy()
        lookup_drones[eid] = nil
    end
end

local function __get_fly_height(location)
    if not location then
        return
    end
    local x, y = ((location >> 24) & 0xFF), (location >> 16) & 0xFF
    local object = objects:coord(x, y)
    if object then
        return iprototype.queryByName(object.prototype_name).drone_height
    end
end

local function __get_position(location)
    local x, y = ((location >> 24) & 0xFF), (location >> 16) & 0xFF
    local object = objects:coord(x, y)
    if not object then
        return math3d.vector(terrain:get_position_by_coord(x, y, 1, 1))
    end

    local idx = (location >> 7) & 0xF

    local building = global.buildings[object.id]
    if not building then
        return math3d.set_index(object.srt.t, 2, item_height)
    end
    local io_shelves = building.io_shelves
    if not io_shelves then
        return math3d.set_index(object.srt.t, 2, item_height)
    end
    local pos = io_shelves:get_heap_position(idx+1)
    if not pos then
        return math3d.set_index(object.srt.t, 2, item_height)
    else
        return pos
    end
end

local function get_fly_height(prev, next)
    local frome_height = __get_fly_height(prev)
    local to_height = __get_fly_height(next)
    local fly_height = default_fly_height
    if frome_height and fly_height < frome_height then
        fly_height = frome_height
    end
    if to_height and fly_height < to_height then
        fly_height = to_height
    end
    return fly_height
end

local drone_to_remove = {}

function drone_sys:gameworld_update()
    local gameworld = gameplay_core.get_world()
    local same_dest_offset = {}
    local drone_task = {}
    for e in gameworld.ecs:select "drone:in eid:in" do
        local drone = e.drone
        assert(drone.prev ~= 0, "drone.prev == 0")
        if drone.status == STATUS_HAS_ERROR then
            if lookup_drones[e.eid] then
                drone_to_remove[#drone_to_remove + 1] = e.eid
            end
            goto continue
        end
        if not lookup_drones[e.eid] then
            lookup_drones[e.eid] = create_drone(get_home_pos(__get_position(drone.prev)))
        else
            local current = lookup_drones[e.eid]
            local flyid = drone.prev << 32 | drone.next
            if current.flyid ~= flyid or current.to_home then
                if drone.maxprogress > 0 then
                    if not same_dest_offset[flyid] then
                        same_dest_offset[flyid] = 0
                    else
                        same_dest_offset[flyid] = same_dest_offset[flyid] - (drone_offset / 2)
                    end

                    local from = __get_position(drone.prev)
                    local to = __get_position(drone.next)
                    local fly_height = get_fly_height(drone.prev, drone.next)
                    -- status : go_home
                    if get_berth(drone.next) == BERTH_HOME then
                        current:gohome(flyid, from, get_home_pos(to), fly_height)
                    else
                        if drone.item ~= 0 then
                            local typeobject_item = iprototype.queryById(drone.item)
                            local item_prefab = imotion.sampler_group:create_instance("/pkg/vaststars.resources/" .. typeobject_item.pile_model, current.prefab.tag["*"][1])
                            item_prefab.on_ready = function(inst)
                                local re <close> = w:entity(inst.tag["*"][1])
                                iom.set_position(re, math3d.vector(0.0, -4.0, 0.0))
                                iom.set_scale(re, math3d.vector(1.5, 1.5, 1.5))
                            end
                            world:create_object(item_prefab)
                            current:set_item(item_prefab)
                        end
                        drone_task[#drone_task + 1] = {flyid, current, from, to, fly_height, drone.maxprogress, drone.maxprogress - drone.progress}
                    end
                elseif get_berth(drone.prev) == BERTH_HOME and not current.to_home then
                    -- status : to_home
                    local dst = __get_position(drone.prev)
                    current:gohome(flyid, math3d.set_index(dst, 2, item_height), get_home_pos(dst), fly_to_home_height, 15)
                end
            else
                current:update(drone.maxprogress > 0 and (drone.maxprogress - drone.progress) / drone.maxprogress or 0, drone.item ~= 0)
            end
        end
        ::continue::
    end
    for _, task in ipairs(drone_task) do
        local flyid = task[1]
        local to = math3d.add(task[4], {same_dest_offset[flyid], 0, 0})
        task[2]:flyto(flyid, task[5], task[3], to, false, task[6], task[7])
        same_dest_offset[flyid] = same_dest_offset[flyid] + drone_offset
    end
end

function drone_sys:gameworld_clean()
    for _, drone in pairs(lookup_drones) do
        drone:destroy()
    end
    lookup_drones = {}
end

function drone_sys:end_frame()
    if #drone_to_remove == 0 then
        return
    end
    for _, deid in ipairs(drone_to_remove) do
        remove_drone(deid)
    end
    drone_to_remove = {}
end