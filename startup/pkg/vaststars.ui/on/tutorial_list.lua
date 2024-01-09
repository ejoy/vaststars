local fs = require "filesystem"

return function (window)
    local tutorials = {}
    for path in fs.pairs(fs.path("/pkg/vaststars.prototype/template/")) do
        if not fs.is_directory(path) then
            assert(tostring(path:extension()) == ".lua")
            if not path:filename():string():match("^tutorial.*$") then
                goto continue
            end

            local f = dofile(path:string())
            if f.show == false then
                goto continue
            end

            tutorials[#tutorials + 1] = {
                order = f.order or 0,
                name = f.name or "undef",
                template = "template." .. path:stem():string(),
                desc = f.tutorial_desc or "",
                details = f.tutorial_details or {},
                background = f.tutorial_background or "",
            }
            ::continue::
        end
    end
    table.sort(tutorials, function(a, b) return a.order < b.order end)

    local model = window.createModel {
        name = tutorials[1] and tutorials[1].name or "",
        tutorials = tutorials,
    }

    function model.open(filename)
        local audio = import_package "ant.audio"
        audio.play "event:/ui/button1"
        window.callMessage("reboot", "new_game", filename)
        window.close()
    end

    function model.clickTab(name)
        model.name = name
    end

    function model.clickClose()
        window.close()
    end
end
