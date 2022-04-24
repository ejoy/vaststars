local ecs = ...
local world = ecs.world

local gameplay_core = ecs.require "gameplay.core"
local fs = require "bee.filesystem"
local construct_editor = ecs.require "construct_editor"
local gameplay = import_package "vaststars.gameplay"
local general = require "gameplay.utility.general"
local dir_tostring = general.dir_tostring

local archival_path = "/pkg/vaststars/archiving/"
archival_path = fs.exe_path():parent_path()
archival_path = archival_path / [[../../../archiving/]]
archival_path = archival_path:lexically_normal():string()

local function restore_world()
    -- clean
    construct_editor.reset()

    -- restore
    for v in gameplay_core.select("entity:in") do
        local e = v.entity
        local typeobject = gameplay.query(e.prototype)
        construct_editor.restore_object(typeobject.name, dir_tostring(e.direction), e.x, e.y)
    end
end

local M = {}
function M:backup()
    gameplay_core.backup(archival_path)
    print("save success")
end

function M:restore()
    gameplay_core.restore(archival_path)
    restore_world()
    print("restore success")
end

function M:restart()
    -- clean
    gameplay_core.clean()
    construct_editor.reset()
end

local saveload_sys = ecs.system "saveload_system"
local ui_saveload_save_mb = world:sub {"ui", "saveload", "save"}
local ui_saveload_restore_mb = world:sub {"ui", "saveload", "restore"}
local ui_saveload_restart_mb = world:sub {"ui", "saveload", "restart"}

function saveload_sys:update_world()
    for _ in ui_saveload_save_mb:unpack() do
        M:backup()
    end

    for _ in ui_saveload_restore_mb:unpack() do
        M:restore()
    end

    for _ in ui_saveload_restart_mb:unpack() do
        M:restart()
    end
end
