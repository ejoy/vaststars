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
local all_drones = {}
local heap_items = {}
local heap_item_name = "iron-ingot"
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

local function create_drone(home)
    local task = {
        home = home,
        stage = 0,--{0,1,2}
        running = false,
        elapsed_time = 0,
        start_duration = 0,
        end_duration = 0,
        duration = 0,
        gohome = function (self)
            self:flyto(14, self.home, 1.0)
        end,
        flyto = function (self, height, to, duration)
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
                        iheapmesh.update_heap_mesh_number(math.random(10, 27), heap_item_name)
                    end
                end
            end
        end
    }
    local motion_xz = create_motion_object(nil, nil, math3d.vector(home[1], 0, home[3]))
    task.motion_xz = motion_xz
    local motion_y = create_motion_object(nil, nil, math3d.vector(0, home[2], 0), motion_xz)
    task.prefab = sampler_group:create_instance("/pkg/vaststars.resources/prefabs/drone.prefab", motion_y)
    task.motion_y = motion_y
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
            material = "/pkg/ant.resources/materials/heap_test.material", -- 自定义material文件中需加入HEAP_MESH :1
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

local function update_world(gameworld)
    local t = {}
    --TODO: update framerate is 30
    local elapsed_time = 1.0 / 30
    local fly_height = 15
    local item_height = 8
    for e in gameworld.ecs:select "drone:in eid:in" do
        -- local drone = e.drone
        -- if not all_drones[e.eid] then
        --     local obj = get_object(drone.home)
        --     local pos = obj.srt.t
        --     local new_drone = create_drone({pos[1] + 6, pos[2] + item_height, pos[3] - 6})
        --     if not heap_items[obj.prototype_name] then
        --         heap_items[obj.prototype_name] = create_heap_items(heap_item_name, "/pkg/vaststars.resources/glb/iron-ingot.glb|meshes/Cube.252_P1.meshbin", {s = 1, t = {pos[1], pos[2] + item_height, pos[3]}}, 3, 10)
        --     end
        --     new_drone.heap_items_name = heap_item_name
        --     all_drones[e.eid] = new_drone
        -- else
        --     local current = all_drones[e.eid]
        --     if not current.running and (drone.prev > 0 or drone.next > 0) then
        --         if not current.start_progress then
        --             current.start_progress = drone.progress
        --         else
        --             local stepCount = drone.maxprogress / (current.start_progress - drone.progress)
        --             local total = stepCount * elapsed_time
        --             local duration = (current.start_progress / drone.maxprogress) * total
        --             current.start_progress = nil

        --             local obj = get_object(drone.next)
        --             if obj then
        --                 local pos = obj.srt.t
        --                 current:flyto(fly_height, {pos[1], item_height, pos[3]}, duration)
        --                 if drone.item then
        --                     current.item = create_item(drone.item, current.prefab.tag["*"][1])
        --                 end
        --             end
        --         end
        --     else
        --         current:update(elapsed_time)
        --     end
        -- end
        -- print(drone.prev, drone.next, drone.maxprogress, drone.progress, drone.item)
    end
    return t
end
return update_world