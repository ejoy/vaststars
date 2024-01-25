local ltask = require "ltask"
local fs = require "bee.filesystem"
local vfsrepo = import_package "ant.vfs"
local cr = import_package "ant.compile_resource"

return function (repopath, reskey)
    repopath = fs.path(repopath)

    local resource_cache = {}

    do print "step1. check resource cache."
        for _, setting in ipairs(reskey) do
            if fs.exists(repopath / "res" / setting) then
                for path, status in fs.pairs(repopath / "res" / setting) do
                    if status:is_directory() then
                        for res in fs.pairs(path) do
                            resource_cache[res:string()] = true
                        end
                    end
                end
            end
        end
    end

    do print "step2. compile resource."
        local std_vfs <close> = vfsrepo.new_std {
            rootpath = repopath,
            nohash = true,
        }
        local tiny_vfs = vfsrepo.new_tiny(repopath)
        local names, paths = std_vfs:export_resources()
        local tasks = {}
        local has_error
        local function msgh(errmsg)
            return debug.traceback(errmsg)
        end
        local function compile_resource(cfg, name, path)
            local ok, lpath = xpcall(cr.compile_file, msgh, cfg, name, path)
            if ok then
                resource_cache[lpath] = nil
                return
            end
            has_error = true
            print(string.format("compile failed:\n\tvpath: %s\n\tlpath: %s\n%s", name, path, lpath))
        end
        for _, setting in ipairs(reskey) do
            local cfg = cr.init_setting(tiny_vfs, setting)
            for i = 1, #names do
                tasks[#tasks+1] = { compile_resource, cfg, names[i], paths[i] }
            end
        end
        for _ in ltask.parallel(tasks) do
        end
        if has_error then
            return
        end
    end

    do print "step3. clean resource."
        for path in pairs(resource_cache) do
            fs.remove_all(path)
        end
    end
end
