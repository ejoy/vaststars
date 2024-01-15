local fs = require "filesystem"

return function (window, document)
    local templates = {}
    for path in fs.pairs(fs.path("/pkg/vaststars.prototype/template/")) do
        if not fs.is_directory(path) then
            assert(tostring(path:extension()) == ".lua")
            if path:filename():string():match("^tutorial.*$") then
                goto continue
            end
            local f = dofile(path:string())
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
        for _, e in ipairs(document.getElementsByTagName "template-list") do
            e.scrollInsets(0, 0, 0, 200)
            local last_y
            e.addEventListener("pan", function(param)
                if last_y and param.state == "changed" then
                    e.scrollTop = e.scrollTop - (param.y - last_y)
                end
                last_y = param.y
            end)
        end
    end
end
