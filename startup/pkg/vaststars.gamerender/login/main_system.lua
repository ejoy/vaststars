local ecs = ...
local world = ecs.world

local m = ecs.system "login_main_system"

local iRmlUi = ecs.require "ant.rmlui|rmlui_system"
local font = import_package "ant.font"
local window

font.import "/pkg/vaststars.resources/ui/font/Alibaba-PuHuiTi-Regular.ttf"

function m:init()
    window = iRmlUi.open "/pkg/vaststars.resources/ui/login_logo.html"
    iRmlUi.onMessage("login-loaded", function ()
        log.info("Load login scene.")
        world:import_feature "vaststars.gamerender|login_scene"
    end)
end

function m:exit()
    iRmlUi.onMessage "login-loaded"
    window.close()
end
