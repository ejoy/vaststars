local ecs = ...
local world = ecs.world

local m = ecs.system "login_main_system"

local iRmlUi = ecs.require "ant.rmlui|rmlui_system"
local font = import_package "ant.font"
local window
local loading

font.import "/pkg/vaststars.resources/ui/font/Alibaba-PuHuiTi-Regular.ttf"

function m:init()
    window = iRmlUi.open "/pkg/vaststars.resources/ui/login_logo.rml"

    local iversion = import_package "vaststars.version"
    local vfs = require "vfs"
    local version = "IN DEVELOPMENT " .. table.concat({
        string.sub(iversion.game, 1, 6),
        string.sub(iversion.engine, 1, 6),
        string.sub(vfs.version(), 1, 6),
    }, "-")
    window.postMessage {
        type = "set",
        data = {
            version = version,
        },
    }
    window.addEventListener("message", function (data)
        if data.type == "loaded" then
            loading = true
        end
    end)
end

function m:exit()
    window.close()
end

function m:final()
    if loading then
        loading = nil
        log.info("Load login scene.")
        world:import_feature "vaststars.gamerender|login_scene"
    end
end
