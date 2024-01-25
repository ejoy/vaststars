local ltask = require "ltask"
local download = require "download"
local download_dir = require "download_dir"
local fs = require "bee.filesystem"

local CDN <const> = "https://antengine-server-patch.ejoy.com/"

return function (dir, version, reskey)
    local fetch_dir_tasks = {}
    local fetch_file_tasks = {}
    local function fetch_file(path)
        local filepath = fs.path(dir..path)
        if not fs.exists(filepath) then
            fs.create_directories(filepath:remove_filename())
            download(CDN..version.."/"..path, filepath:string())
        end
    end
    local function fetch_dir(name)
        for file in pairs(download_dir(CDN..version.."/"..name.."/")) do
            fetch_file_tasks[#fetch_file_tasks+1] = { fetch_file, name.."/"..file }
        end
    end
    fetch_dir_tasks[#fetch_dir_tasks+1] = { fetch_dir, "core" }
    for _, setting in ipairs(reskey) do
        fetch_dir_tasks[#fetch_dir_tasks+1] = { fetch_dir, setting }
    end
    for _ in ltask.parallel(fetch_dir_tasks) do
    end
    for _ in ltask.parallel(fetch_file_tasks) do
    end
end
