local fs = require "filesystem"
local pm = require "packagemanager"
local init_scroll_list = require "scroll_list".init

return function (window, document)
    local templates = {}
    for path in fs.pairs "/pkg/vaststars.prototype/template/" do
        if not fs.is_directory(path) then
            assert(path:extension() == ".lua")
            if path:filename():string():match("^tutorial.*$") then
                goto continue
            end
            local f = pm.loadenv("vaststars.prototype").dofile("template/"..path:filename():string())
            if f.show == false then
                goto continue
            end
            templates[#templates + 1] = {
                order = f.order or 0,
                mode = f.mode,
                name = f.name or "undef",
                filename = "template." .. path:stem():string(),
            }
            ::continue::
        end
    end
    table.sort(templates, function(a, b) return a.order < b.order end)

    local model = window.createModel {
        templates = templates,
    }

    function model.open(filename)
        window.callMessage("reboot", "new_game", filename)
        window.close()
    end

    function window.onload()
        init_scroll_list(document, {"template-list"})
    end
end
