local ecs = ...
local world = ecs.world
local w = world.w

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local CONSTANT <const> = require "gameplay.interface.constant"
local UPS <const> = CONSTANT.UPS

local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"
local objects = require "objects"
local ims = ecs.require "ant.motion_sampler|motion_sampler"
local iprototype = require "gameplay.interface.prototype"
local ltween = require "motion.tween"
local imotion = ecs.require "imotion"
local drone_sys = ecs.system "drone_system"
local gameplay_core = require "gameplay.core"
local global = require "global"
local icoord = require "coord"
local irl   = ecs.require "ant.render|render_layer.render_layer"
local igroup = ecs.require "group"
local vsobject_manager = ecs.require "vsobject_manager"

-- enum defined in c 
local STATUS_HAS_ERROR = 1
local lookup_drones = {}
local drone_offset = 6
local default_fly_height = 20
local fly_to_home_height = 15
local item_height = 15

local function getFlyHeight(x, y)
    local object = objects:coord(x, y)
    if object then
        return iprototype.queryByName(object.prototype_name).drone_height
    end
end

local function getPosition(x, y, slot)
    local object = objects:coord(x, y)
    if not object then
        return math3d.vector(icoord.position(x, y, 1, 1))
    end

    local io_shelves
    local building = global.buildings[object.id]
    if building then
        io_shelves = building.io_shelves
    end

    if io_shelves then
        -- parking slot base 0
        return assert(io_shelves:get_item_position(slot + 1))
    else
        return math3d.set_index(object.srt.t, 2, item_height) -- TODO: if the building doesn't have shelves, then get the building's parking slots
    end
end

local function getGameObject(object)
    local vsobject = vsobject_manager:get(object.id) or error(("(%s) vsobject not found"):format(object.prototype_name))
    return vsobject.game_object
end

local function isHome(x, y)
    local object = objects:coord(x, y)
    if object then
        local typeobject = iprototype.queryByName(object.prototype_name)
        return iprototype.has_types(typeobject.type, "airport")
    end
    return false
end

local function getHomePos(x, y, pos)
    local object = objects:coord(x, y)
    if not object then
        return pos
    end

    if not isHome(x, y) then
        return math3d.set_index(pos, 2, item_height)
    end

    local game_object = assert(getGameObject(object))
    local worldmat = game_object:get_slot_position("park")
    return math3d.index(worldmat, 4)
end

local function create_drone(x, y, slot)
    local homepos = getHomePos(x, y, getPosition(x, y, slot))
    local task = {
        flying = false,
        duration = 0,
        elapsed = 0,
        to_home = false,
        at_home = false,
        flyid = 0,
        gohome = function (self, flyid, from, to, fly_height, duration)
            -- fix move drone airport
            -- if self.to_home then return end
            self:destroy_item()
            self:flyto(flyid, fly_height, from, to, true, duration or UPS)
            self.to_home = true
        end,
        flyto = function (self, flyid, height, from, to, home, duration, start)
            self.at_home = false
            self.flyid = flyid
            if self.to_home and not home then
                local exz <close> = world:entity(self.motion_xz)
                local xzpos = iom.get_position(exz)
                local ey <close> = world:entity(self.motion_y)
                local xpos = iom.get_position(ey)
                from = math3d.vector {math3d.index(xzpos, 1), math3d.index(xpos, 2), math3d.index(xzpos, 3)}
                self.to_home = false
            end
            local exz <close> = world:entity(self.motion_xz)
            ims.set_tween(exz, ltween.type("Sine"), ltween.type("Sine"))
            ims.set_keyframes(exz,
                {t = math3d.set_index(from, 2, 0), step = 0.0},
                {t = math3d.set_index(to, 2, 0),  step = 1.0}
            )
            local ey <close> = world:entity(self.motion_y)
            ims.set_tween(ey, ltween.type("Quartic"), ltween.type("Quartic"))
            ims.set_keyframes(ey,
                {t = math3d.vector({0, math3d.index(from, 2), 0}), step = 0.0},
                {t = math3d.vector({0, height, 0}), step = 0.1},
                {t = math3d.vector({0, height, 0}), step = 0.9},
                {t = math3d.vector({0, math3d.index(to, 2), 0}),  step = 1.0}
            )
            ims.set_duration(exz, duration, start or 0, true)
            ims.set_duration(ey, duration, start or 0, true)
            self.flying = true
        end,
        update = function (self, step, hasitem)
            if not self.flying then
                return
            end
            local finished = false
            if self.to_home then
                self.elapsed = self.elapsed + 1
                if self.elapsed >= self.duration then
                    finished = true
                    self.home = true
                end
            else
                if step >= 1.0 then
                    finished = true
                end
            end
            if finished then
                self.flying = false
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
            world:remove_instance(self.item)
            self.item = nil
        end,
        destroy = function (self)
            self:destroy_item()
            world:remove_instance(self.prefab)
            w:remove(self.motion_y)
            w:remove(self.motion_xz)
        end,
    }
    local motion_xz = imotion.create_motion_object(nil, nil, math3d.set_index(homepos, 2, 0))
    task.motion_xz = motion_xz
    local motion_y = imotion.create_motion_object(nil, nil, math3d.vector(0, math3d.index(homepos, 2), 0), motion_xz)
    task.motion_y = motion_y
    task.prefab = world:create_instance {
        prefab = "/pkg/vaststars.resources/glbs/drone.glb|mesh.prefab",
        parent = motion_y,
        group = igroup.id(x, y),
        on_ready = function(self)
            for _, eid in ipairs(self.tag["*"]) do
                local e <close> = world:entity(eid, "render_object?update")
                if e.render_object then
                    irl.set_layer(e, RENDER_LAYER.DRONE)
                end
            end
        end
    }
    return task
end

local function remove_drone(eid)
    if lookup_drones[eid] then
        lookup_drones[eid]:destroy()
        lookup_drones[eid] = nil
    end
end

local function get_fly_height(prev_x, prev_y, next_x, next_y)
    local frome_height = getFlyHeight(prev_x, prev_y)
    local to_height = getFlyHeight(next_x, next_y)
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
    local gameplay_world = gameplay_core.get_world()
    local gameplay_ecs = gameplay_world.ecs

    local same_dest_offset = {}
    local drone_task = {}
    for e in gameplay_ecs:select "drone_changed drone:in eid:in" do
        local drone = e.drone
        if drone.status == STATUS_HAS_ERROR then
            if lookup_drones[e.eid] then
                drone_to_remove[#drone_to_remove + 1] = e.eid
            end
            goto continue
        end
        if not lookup_drones[e.eid] then
            lookup_drones[e.eid] = create_drone(drone.prev_x, drone.prev_y, drone.prev_slot)
        else
            local current = lookup_drones[e.eid]
            if drone.item ~= 0 then
                local typeobject_item = iprototype.queryById(drone.item)
                local item_prefab = world:create_instance {
                    prefab = "/pkg/vaststars.resources/" .. typeobject_item.item_model,
                    parent = current.prefab.tag["*"][1],
                    group = current.prefab.group,
                    on_ready = function(inst)
                        local re <close> = world:entity(inst.tag["*"][1])
                        iom.set_position(re, math3d.vector(0.0, -4.0, 0.0))
                        iom.set_scale(re, math3d.vector(1.5, 1.5, 1.5))
                    end
                }
                current:set_item(item_prefab)
            else
                current:destroy_item()
            end

            local flyid = drone.prev_x | (drone.prev_y << 16) | (drone.prev_slot << 24) | (drone.next_x << 28) | (drone.next_y << 30) | (drone.next_slot << 32)
            if current.flyid ~= flyid or current.to_home then
                if drone.maxprogress > 0 then
                    if not same_dest_offset[flyid] then
                        same_dest_offset[flyid] = 0
                    else
                        same_dest_offset[flyid] = same_dest_offset[flyid] - (drone_offset / 2)
                    end

                    local from = getPosition(drone.prev_x, drone.prev_y, drone.prev_slot)
                    local to = getPosition(drone.next_x, drone.next_y, drone.next_slot)
                    local fly_height = get_fly_height(drone.prev_x, drone.prev_y, drone.next_x, drone.next_y)
                    -- status : go_home
                    if isHome(drone.next_x, drone.next_y) then
                        current:gohome(flyid, from, getHomePos(drone.next_x, drone.next_y, to), fly_height)
                    else
                        drone_task[#drone_task + 1] = {flyid, current, from, to, fly_height, drone.maxprogress, drone.maxprogress - drone.progress}
                    end
                elseif isHome(drone.prev_x, drone.prev_y) and not current.to_home then
                    -- status : to_home
                    local dst = getPosition(drone.prev_x, drone.prev_y, drone.prev_slot)
                    current:gohome(flyid, math3d.set_index(dst, 2, item_height), getHomePos(drone.prev_x, drone.prev_y, dst), fly_to_home_height, 15)
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
    gameplay_ecs:clear("drone_changed")
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