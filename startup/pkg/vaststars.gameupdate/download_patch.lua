local ltask = require "ltask"
local download = require "download"
local download_dir = require "download_dir"
local fs = require "bee.filesystem"

local CDN <const> = "https://antengine-server-patch.ejoy.com/"

return function (dir, version, reskey, min_index)
    local fetch_dir_tasks = {}
    local fetch_file_tasks = {}
    local function fetch_file(path)
        local filepath = dir / path
        if not fs.exists(filepath) then
            fs.create_directories(filepath:parent_path())
            download(CDN..version.."/"..path, filepath:string())
        end
    end
    local function fetch_dir(name)
        for file in pairs(download_dir(CDN..version.."/"..name.."/")) do
            local index = file:match "^(%d%d).*$"
            if index and math.tointeger(index) >= min_index then
                fetch_file_tasks[#fetch_file_tasks+1] = { fetch_file, name.."/"..file }
            end
        end
    end
    fetch_dir_tasks[#fetch_dir_tasks+1] = { fetch_dir, "core" }
    for _, setting in ipairs(reskey) do
        fetch_dir_tasks[#fetch_dir_tasks+1] = { fetch_dir, setting }
    end
    for _, resp in ltask.parallel(fetch_dir_tasks) do
        if resp.error then
            resp:rethrow()
        end
    end
    for _, resp in ltask.parallel(fetch_file_tasks) do
        if resp.error then
            resp:rethrow()
        end
    end
end
