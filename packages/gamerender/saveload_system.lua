local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local fs = require "bee.filesystem"
local construct_editor = ecs.require "construct_editor"
local json = import_package "ant.json"
local archival_base_dir = (fs.appdata_path() / "vaststars/archiving"):string()
local archiving_list_path = archival_base_dir .. "/archiving.json"
local camera_setting_path = archival_base_dir .. "/camera.json"
local iprototype = require "gameplay.prototype"
local startup_entities = import_package("vaststars.prototype")("item.startup").entities
local camera = ecs.require "engine.camera"

local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local math3d = require "math3d"

local MAX_ARCHIVING_COUNT <const> = 9

local archival_relative_dir_list = {}

local function restore_world()
    -- clean
    construct_editor.reset()

    -- restore
    for v in gameplay_core.select("id:in entity:in") do
        local e = v.entity
        local typeobject = iprototype:query(e.prototype)
        construct_editor.restore_object(v.id, typeobject.name, iprototype:dir_tostring(e.direction), e.x, e.y)
    end
    gameplay_core.build()
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
    local ce = world:entity(irq.main_camera())
    local t = {
        s = math3d.tovalue(iom.get_scale(ce)),
        r = math3d.tovalue(iom.get_rotation(ce)),
        t = math3d.tovalue(iom.get_position(ce)),
        frustum = ic.get_frustum(ce),
    }
    return t
end

local function restore_camera_setting(camera_setting)
    local ce = world:entity(irq.main_camera())
    iom.set_srt(ce, camera_setting.s, camera_setting.r, camera_setting.t)
    ic.set_frustum(ce, camera_setting.frustum)
end

local M = {}
function M:backup()
    while #archival_relative_dir_list + 1 > MAX_ARCHIVING_COUNT do
        local archival_relative_dir = table.remove(archival_relative_dir_list, 1)
        local archival_dir = archival_base_dir .. ("/%s"):format(archival_relative_dir)
        print("remove", archival_dir)
        fs.remove_all(archival_dir)
    end

    local t = os.date("*t")
    local dn = ("%04d-%02d-%02d-%02d-%02d-%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
    local archival_dir = archival_base_dir .. ("/%s"):format(dn)

    archival_relative_dir_list[#archival_relative_dir_list + 1] = dn
    gameplay_core.backup(archival_dir)

    writeall(archiving_list_path, json.encode(archival_relative_dir_list))
    writeall(camera_setting_path, json.encode(get_camera_setting()))
    print("save success", archival_dir)
end

function M:restore(index)
    local camera_setting
    if fs.exists(fs.path(camera_setting_path)) then
        camera_setting = json.decode(readall(camera_setting_path))
    end

    --
    if not fs.exists(fs.path(archiving_list_path)) then
        return
    end
    archival_relative_dir_list = json.decode(readall(archiving_list_path))
    if #archival_relative_dir_list <= 0 then
        return
    end

    index = index or #archival_relative_dir_list
    if index > #archival_relative_dir_list then
        log.error(("Failed to restore `%s`"):format(index))
        return
    end

    local archival_dir
    while index > 0 do
        local archival_relative_dir = archival_relative_dir_list[index]
        archival_dir = archival_base_dir .. ("/%s"):format(archival_relative_dir)

        if not fs.exists(fs.path(archival_dir)) then
            log.warn(("`%s` not exists"):format(archival_relative_dir))
            archival_relative_dir_list[index] = nil
            index = index - 1
        else
            break
        end
    end

    if index == 0 then
        log.error("Failed to restore")
        return
    end

    gameplay_core.restore(archival_dir)
    restore_world()

    if camera_setting then
        restore_camera_setting(camera_setting)
    end
    print("restore success", archival_dir)
end

function M:restart()
    gameplay_core.restart()

    for _, e in ipairs(startup_entities) do
        gameplay_core.create_entity(e)
    end
    restore_world()
end

local saveload_sys = ecs.system "saveload_system"
local ui_saveload_save_mb = world:sub {"ui", "saveload", "save"}
local ui_saveload_restore_mb = world:sub {"ui", "saveload", "restore"}
local ui_saveload_restart_mb = world:sub {"ui", "saveload", "restart"}
local ui_construct_show_setting_mb = world:sub {"ui", "construct", "show_setting"}
local iui = ecs.import.interface "vaststars.gamerender|iui"

function saveload_sys:camera_usage()
    for _ in ui_saveload_save_mb:unpack() do -- 存档时会保存摄像机的位置
        M:backup()
    end

    for _, _, _, index in ui_saveload_restore_mb:unpack() do -- 读档时会还原摄像机的位置
        M:restore(index)
    end

    for _ in ui_saveload_restart_mb:unpack() do
        camera.set("camera_default.prefab", true)
        M:restart()
    end
end

function saveload_sys:update_world()
    for _ in ui_construct_show_setting_mb:unpack() do
        iui.open("option_pop.rml", archival_relative_dir_list)
    end
end
