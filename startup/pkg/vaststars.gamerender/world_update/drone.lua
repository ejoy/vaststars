local ecs = ...
local world = ecs.world
local w = world.w
local math3d    = require "math3d"
local mc = import_package "ant.math".constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local iheapmesh = ecs.import.interface "ant.render|iheapmesh"
local gameplay_core = require "gameplay.core"
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
local fly_height = 20
local item_height = 15
local function create_drone(home)
    local task = {
        home = home,
        stage = 0,--{0,1,2}
        running = false,
        elapsed_time = 0,
        start_duration = 0,
        end_duration = 0,
        duration = 0,
        at_home = true,
        gohome = function (self)
            self:flyto(fly_height, self.home, 1.0)
            self.at_home = true
        end,
        flyto = function (self, height, to, duration)
            self.at_home = false
            self.duration = duration
            self.start_duration = duration * 0.25
            self.end_duration = duration * 0.25
            self.end_y = {to = {0, to[2], 0}, tin = mc.TWEEN_QUARTIC, tout = mc.TWEEN_QUARTIC}
            --
            self.moveto(self.motion_xz, {to[1], 0, to[3]}, duration, mc.TWEEN_SINE, mc.TWEEN_SINE)
            self.moveto(self.motion_y, {0, height, 0}, self.start_duration, mc.TWEEN_QUARTIC, mc.TWEEN_QUARTIC)
            self.running = true
        end,
        moveto = function (motion, topos, time, tin, tout)
            local e <close> = w:entity(motion)
            ims.set_target(e, nil, nil, math3d.vector(topos), time * 1000, tin, tout)
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
                    self.moveto(self.motion_y, y.to, self.end_duration, y.tin, y.tout)
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
                        self.owner:update_heap()
                    end
                end
            end
        end
    }
    local motion_xz = create_motion_object(nil, nil, math3d.vector(home[1], 0, home[3]))
    task.motion_xz = motion_xz
    local motion_y = create_motion_object(nil, nil, math3d.vector(0, home[2], 0), motion_xz)
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

local function create_heap_items(glbname, meshname, scene, dimsize, num)
    ecs.create_entity {
        policy = {
            "ant.render|render",
            "ant.general|name",
            "ant.render|heap_mesh",
         },
        data = {
            name    = "heap_items",
            scene   = scene,
            material = "/pkg/ant.resources/materials/pbr_heap.material", -- 自定义material文件中需加入HEAP_MESH :1
            visible_state = "main_view",
            mesh = meshname,
            heapmesh = {
                curSideSize = dimsize,  -- 当前 x y z方向最大堆叠数量均为curSideSize = 3，最大堆叠数为3*3*3 = 27
                curHeapNum = num,  -- 当前堆叠数为10，以x->z->y轴的正方向顺序堆叠。最小为0，最大为10，超过边界值时会clamp到边界值。
                glbName = glbname -- 当前entity对应的glb名字，用于筛选
            }
        },
    }
end
-- iheapmesh.update_heap_mesh_number(27, "iron-ingot") -- 更新当前堆叠数 参数一为待更新堆叠数 参数二为entity筛选的glb名字
-- iheapmesh.update_heap_mesh_sidesize(4, "iron-ingot") -- 更新当前每个轴的最大堆叠数 参数一为待更新每个轴的最大堆叠数 参数二为entity筛选的glb名字
local drone_depot = {}
local lookup_drones = {}
local pile_id = 0
local function update_world(gameworld)
    local t = {}
    --TODO: update framerate is 30
    local elapsed_time = 1.0 / 30
    for e in gameworld.ecs:select "drone:in eid:in" do
        local drone = e.drone
        if not lookup_drones[e.eid] then
            local obj = get_object(drone.home)
            local pos = obj.srt.t
            local objid = obj.id
            if not drone_depot[objid] then
                local e = gameplay_core.get_entity(obj.gameplay_eid)
                local chest = gameworld:container_get(e.hub, 1)
                local typeobject = iprototype.queryById(chest.item)
                pile_id = pile_id + 1
                local pile_name = "pile" .. pile_id
                local pos_offset = {-1, 5, 4}
                drone_depot[objid] = {
                    drones = {},
                    pile_name = pile_name,
                    pile_num = chest.amount,
                    pile_eid = create_heap_items(pile_name, "/pkg/vaststars.resources/"..typeobject.pile_model.."|meshes/Cube_P1.meshbin", {s = 1, t = {pos[1] + pos_offset[1], pos[2] + pos_offset[2], pos[3] + pos_offset[3]}}, 4, 0),
                    update_heap = function (self)
                        self.pile_num = self.pile_num + 1
                        iheapmesh.update_heap_mesh_number(self.pile_num, self.pile_name)
                    end
                }
            end
            local depot = drone_depot[objid]
            local drones = depot.drones
            if not drones[e.eid] then
                local drone = create_drone({pos[1] + 6, pos[2] + 8, pos[3] - 6})
                drone.owner = depot
                drones[e.eid] = drone
                -- cache lookup table
                lookup_drones[e.eid] = drone
            end
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

                        local obj = get_object(drone.next)
                        if obj then
                            local pos = obj.srt.t
                            current:flyto(fly_height, {pos[1], item_height, pos[3]}, duration)
                            if drone.item and (drone.next == drone.home) then
                                current.item = create_item(drone.item, current.prefab.tag["*"][1])
                            end
                        end
                    end
                elseif not current.at_home then
                    current:gohome()
                end
            else
                current:update(elapsed_time)
            end
        end
        -- if drone.maxprogress > 0 then
        --     print(e.eid, drone.prev, drone.next, drone.maxprogress, drone.progress, drone.item)
        -- end
    end
    return t
end
return update_world