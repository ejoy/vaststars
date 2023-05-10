local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local fs = require "bee.filesystem"
local json = import_package "ant.json"
local debugger = require "debugger"
local CUSTOM_ARCHIVING <const> = require "debugger".custom_archiving
local is_roadnet_only = ecs.require "editor.endpoint".is_roadnet_only
local iprototype_cache = require "gameplay.prototype_cache.init"

local archival_base_dir
if CUSTOM_ARCHIVING then
    archival_base_dir = (fs.exe_path():parent_path() / CUSTOM_ARCHIVING):lexically_normal():string()
else
    archival_base_dir = (fs.app_path "vaststars" / "archiving/"):string()
end
local archiving_list_path = archival_base_dir .. "archiving.json"
local camera_setting_path = archival_base_dir .. "camera.json"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local objects = require "objects"
local ifluid = require "gameplay.interface.fluid"
local iscience = require "gameplay.interface.science"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local PROTOTYPE_VERSION <const> = import_package("vaststars.prototype")("version")
local global = require "global"
local create_buildings = require "building_components"

local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local math3d = require "math3d"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local icamera_controller = ecs.interface "icamera_controller"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local iroadnet = ecs.require "roadnet"
local MAX_ARCHIVING_COUNT <const> = 9

local function clean()
    -- clean
    for _, object in objects:all() do
        iobject.remove(object)
    end
    for _, building in pairs(global.buildings) do
        for _, o in pairs(building) do
            o:remove()
        end
    end
    global.buildings = create_buildings()
    objects:clear()
    iroadnet:clear("indicator")
    iroadnet:clear("road")
end

local function restore_world()
    local function _finish_task(task)
        local typeobject = iprototype.queryByName(task)
        gameplay_core.get_world():research_progress(task, typeobject.count)
    end

    local function _debug()
        local guide = import_package "vaststars.prototype"("guide")
        if debugger.skip_guide then
            print("skip guide")
            gameplay_core.get_storage().guide_id = #guide
            iui.set_guide_progress(guide[#guide].narrative_end.guide_progress)

            for _, guide in ipairs(guide) do
                if next(guide.narrative_end.task) then
                    for _, task in ipairs(guide.narrative_end.task) do
                        _finish_task(task)
                    end
                end
            end
        end
    end
    _debug()

    local coord_system = require "global".coord_system

    --
    local function restore_object(gameplay_eid, prototype_name, dir, x, y, fluid_name, fluidflow_id)
        local typeobject = iprototype.queryByName(prototype_name)
        local object = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = {
                t = coord_system:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
            },
            fluid_name = fluid_name,
            fluidflow_id = fluidflow_id,
        }
        object.gameplay_eid = gameplay_eid
        objects:set(object)
    end

    -- restore
    local all_object = {}
    local map = {} -- coord -> id
    local fluidbox_map = {} -- coord -> id -- only for fluidbox
    for v in gameplay_core.select("eid:in building:in fluidbox?in fluidboxes?in assembling?in") do
        local e = v.building
        local typeobject = iprototype.queryById(e.prototype)
        local fluid_name = ""
        if v.fluidbox then
            fluid_name = ""
            if v.fluidbox.fluid == 0 then
                fluid_name = ""
            else
                local typeobject_fluid = assert(iprototype.queryById(v.fluidbox.fluid))
                fluid_name = typeobject_fluid.name
            end
            local w, h = iprototype.rotate_area(typeobject.area, iprototype.dir_tostring(e.direction))
            for i = 0, w - 1 do
                for j = 0, h - 1 do
                    local coord = iprototype.packcoord(e.x + i, e.y + j)
                    assert(fluidbox_map[coord] == nil, ("duplicate fluidbox coord: %d, %d"):format(e.x + i, e.y + j))
                    fluidbox_map[coord] = v.eid
                end
            end
        end
        if v.fluidboxes then
            fluid_name = {}
            for id, fluid in pairs(v.fluidboxes) do
                if fluid ~= 0 then
                    local iotype, index = id:match("(%a+)(%d+)%_fluid")
                    if iotype then
                        local classity = ifluid:iotype_to_classity(iotype)
                        local typeobject_fluid = assert(iprototype.queryById(fluid))

                        fluid_name[classity] = fluid_name[classity] or {}
                        fluid_name[classity][tonumber(index)] = typeobject_fluid.name
                    end
                end
            end
        end

        all_object[v.eid] = {
            prototype_name = typeobject.name,
            dir = iprototype.dir_tostring(e.direction),
            x = e.x,
            y = e.y,
            fluid_name = fluid_name,
            -- fluidflow_id, -- fluidflow_id is not null only when the object is a fluidbox
        }

        local w, h = iprototype.rotate_area(typeobject.area, iprototype.dir_tostring(e.direction))
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                local coord = iprototype.packcoord(e.x + i, e.y + j)
                assert(map[coord] == nil, ("duplicate fluidbox coord: %d, %d"):format(e.x + i, e.y + j))
                map[coord] = v.eid
            end
        end

        world:pub {"gameplay", "create_entity", v.eid, typeobject}
    end

    local function find_pipe_to_ground(c, map)
        local succ, x, y
        for i = 1, c.ground do
            succ, x, y = terrain:move_coord(c.x, c.y, c.dir, i)
            if not succ then
                goto continue
            end

            local object_id = map[iprototype.packcoord(x, y)]
            if not object_id then
                goto continue
            end

            local object = assert(all_object[object_id])
            for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
                if v.ground and v.dir == iprototype.reverse_dir(c.dir) then
                    return x, y
                end
            end

            ::continue::
        end
    end

    local function match_fluidbox(object, dx, dy)
        local succ, x, y
        for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
            if not v.ground then
                succ, x, y = terrain:move_coord(v.x, v.y, v.dir, 1)
                if succ and x == dx and y == dy then
                    return true
                end
            end
        end
    end

    local function fluidbox_dfs(all_object, map, object, input_dir)
        for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
            if v.dir == input_dir then
                goto continue
            end

            local succ, x, y
            if not v.ground then
                succ, x, y = terrain:move_coord(v.x, v.y, v.dir, 1)
                if not succ then
                    goto continue -- out of bound
                end
            else
                x, y = find_pipe_to_ground(v, map)
            end

            if not x or not y then
                goto continue
            end

            local neighbor_id = map[iprototype.packcoord(x, y)]
            if not neighbor_id then
                goto continue
            end

            local neighbor = assert(all_object[neighbor_id])
            if not iprototype.has_type(iprototype.queryByName(neighbor.prototype_name).type, "fluidbox") then
                goto continue
            end

            -- check if the neighbor is close to the fluidbox(v)
            if not v.ground and not match_fluidbox(neighbor, v.x, v.y) then
                goto continue
            end

            assert(neighbor.fluid_name == object.fluid_name)
            if neighbor.fluidflow_id then
                goto continue
            end

            neighbor.fluidflow_id = object.fluidflow_id
            fluidbox_dfs(all_object, map, neighbor, iprototype.reverse_dir(v.dir))
            ::continue::
        end
    end

    for _, id in pairs(fluidbox_map) do
        local object = all_object[id]
        if not object.fluidflow_id then
            global.fluidflow_id = global.fluidflow_id + 1
            object.fluidflow_id = global.fluidflow_id
            fluidbox_dfs(all_object, fluidbox_map, object)
        end
    end

    -----------
    for id, v in pairs(all_object) do
        restore_object(id, v.prototype_name, v.dir, v.x, v.y, v.fluid_name, v.fluidflow_id)
    end

    iobject.flush()
    iscience.update_tech_list(gameplay_core.get_world())
    -- update power network
    ipower:build_power_network(gameplay_core.get_world())
    ipower_line.update_line(ipower:get_pole_lines())
    global.statistic.valid = false
end

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

local function get_camera_setting()
    local ce <close> = w:entity(irq.main_camera())
    local t = {
        s = math3d.tovalue(iom.get_scale(ce)),
        r = math3d.tovalue(iom.get_rotation(ce)),
        t = math3d.tovalue(iom.get_position(ce)),
        frustum = ic.get_frustum(ce),
    }
    return t
end

local M = {running = false}
function M:restore_camera_setting()
    if fs.exists(fs.path(camera_setting_path)) then
        local camera_setting = json.decode(readall(camera_setting_path))
        local ce <close> = w:entity(irq.main_camera())
        iom.set_srt(ce, camera_setting.s, camera_setting.r, camera_setting.t)
        ic.set_frustum(ce, camera_setting.frustum)
    end

    if terrain.init then
        local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
    end
end

function M:backup()
    if not self.running then
        log.error("not running")
        return false
    end

    local archival_list = M:get_archival_list()
    while #archival_list + 1 > MAX_ARCHIVING_COUNT do
        local archival = table.remove(archival_list, 1)
        local archival_dir = archival_base_dir .. ("%s"):format(archival.dir)
        print("remove", archival_dir)
        fs.remove_all(archival_dir)
    end

    local t = os.date("*t")
    local dn = ("%04d-%02d-%02d-%02d-%02d-%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
    local archival_dir = archival_base_dir .. ("%s"):format(dn)

    archival_list[#archival_list + 1] = {dir = dn}
    gameplay_core.backup(archival_dir)

    writeall(archival_dir .. "/version", json.encode({PROTOTYPE_VERSION = PROTOTYPE_VERSION}))
    writeall(archiving_list_path, json.encode(archival_list))
    writeall(camera_setting_path, json.encode(get_camera_setting()))
    print("save success", archival_dir)
    return true
end

function M:clean()
    clean()
end

function M:restore(index)
    self:restore_camera_setting()

    --
    if not fs.exists(fs.path(archiving_list_path)) then
        self:restart()
        return true
    end
    local archival_list = json.decode(readall(archiving_list_path))
    if #archival_list <= 0 then
        self:restart()
        return true
    end

    index = index or #archival_list
    if index > #archival_list then
        log.error(("Failed to restore `%s`"):format(index))
        iui.open({"option_pop.rml"})
        return false
    end

    local archival_dir
    while index > 0 do
        local archival_relative_dir = archival_list[index].dir
        archival_dir = archival_base_dir .. ("%s"):format(archival_relative_dir)

        if not fs.exists(fs.path(archival_dir)) then
            log.warn(("`%s` not exists"):format(archival_relative_dir))
            archival_list[index] = nil
            index = index - 1
            goto continue
        end

        if not fs.exists(fs.path(archival_dir .. "/version")) then
            log.warn(("`%s` not exists"):format(archival_dir .. "/version"))
            archival_list[index] = nil
            index = index - 1
            goto continue
        end

        local version = json.decode(readall(archival_dir .. "/version"))
        if version.PROTOTYPE_VERSION ~= PROTOTYPE_VERSION then
            log.error(("Failed `%s` version `%s` current `%s`"):format(archival_relative_dir, archival_list[index].version, PROTOTYPE_VERSION))
            iui.open({"option_pop.rml"})
            return false
        else
            break
        end

        ::continue::
    end

    if index == 0 then
        log.error("Failed to restore")
        iui.open({"option_pop.rml"})
        return false
    end

    self.running = true
    gameplay_core.restore(archival_dir)
    iprototype_cache.reload()

    clean()
    local map = gameplay_core.get_world():roadnet_get_map()
    local renderData = {}
    for coord, mask in pairs(map) do
        if not is_roadnet_only(mask) then
            local shape, dir = iroadnet_converter.mask_to_shape_dir(mask)
            local x, y = iprototype.unpackcoord(coord)
            renderData[coord] = {x, y, "normal", shape, dir}
        end
    end
    iroadnet:init(renderData, true)
    global.roadnet = map
    gameplay_core.build()

    iscience.update_tech_list(gameplay_core.get_world())
    debugger.set_free_mode(gameplay_core.get_storage().game_mode == "free")
    restore_world()

    iui.open({"construct.rml"})
    iui.open({"message_pop.rml"})
    print("restore success", archival_dir)
    return true
end

function M:restart(mode, startup_lua)
    gameplay_core.restart()
    iprototype_cache.reload()

    self.running = true
    local cw = gameplay_core.get_world()
    iscience.update_tech_list(cw)
    iguide.world = cw
    iui.set_guide_progress(iguide.get_progress())

    local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
    if coord then
        terrain:enable_terrain(coord[1], coord[2])
    end

    startup_lua = startup_lua or "item.startup"
    local startup_entities = import_package("vaststars.prototype")(startup_lua).entities

    --
    clean()
    local map = import_package("vaststars.prototype")(startup_lua).road
    local renderData = {}
    for coord, mask in pairs(map) do
        if not is_roadnet_only(mask) then
            local shape, dir = iroadnet_converter.mask_to_shape_dir(mask)
            local x, y = iprototype.unpackcoord(coord)
            renderData[coord] = {x, y, "normal", shape, dir}
        end
    end
    iroadnet:init(renderData, true)
    global.roadnet = {}
    if next(global.roadnet) then
        gameplay_core.get_world():roadnet_reset(global.roadnet)
    end

    --
    for _, e in ipairs(startup_entities) do
        igameplay.create_entity(e)
    end
    gameplay_core.build()

    iui.open({"construct.rml"})
    iui.open({"message_pop.rml"})
    if mode then
        gameplay_core.get_storage().game_mode = mode
    end
    restore_world()
end

function M:get_archival_list()
    if not fs.exists(fs.path(archiving_list_path)) then
        return {}
    end
    return json.decode(readall(archiving_list_path))
end

return M