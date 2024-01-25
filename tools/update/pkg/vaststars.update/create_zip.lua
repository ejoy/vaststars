local zip = require "zip"
local vfsrepo = import_package "ant.vfs"
local fs = require "bee.filesystem"

return function (zippath, repopath, reskey, ignore1, ignore2)
    fs.create_directories(fs.path(zippath):remove_filename())
    local std_vfs <close> = vfsrepo.new_std {
        rootpath = repopath,
        resource_settings = reskey,
    }
    local zipfile = assert(zip.open(zippath, "w"))
    for hash, v in pairs(std_vfs._filehash) do
        if not ignore1[hash] and not ignore2[hash] then
            if v.dir then
                zipfile:add(hash, v.dir)
            else
                zipfile:addfile(hash, v.path)
            end
        end
    end
    zipfile:close()
    return std_vfs:root()
end
