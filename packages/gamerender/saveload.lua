local ecs = ...
local gameplay_core = ecs.require "gameplay.core"
local fs = require "bee.filesystem"

local M = {}
local archival_path = "/pkg/vaststars/archiving/"
archival_path = fs.exe_path():parent_path()
archival_path = archival_path / [[../../../archiving/]]
archival_path = archival_path:lexically_normal():string()

function M:backup()
    gameplay_core.backup(archival_path)
    print("save success")
end

function M:restore()
    gameplay_core.restore(archival_path)
    for e in gameplay_core.select("entity:in") do
        print(e.x, e.y, e.prototype, e.dir)
    end
    print("save success")
end

function M:restart()
end

return M