local ecs   = ...
local world = ecs.world
local w     = world.w

local math3d = require "math3d"
local bgfx = require "bgfx"

local mathpkg = import_package "ant.math"
local mu, mc = mathpkg.util, mathpkg.constant

local renderpkg = import_package "ant.render"
local declmgr = renderpkg.declmgr

local assetmgr = import_package "ant.asset"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iterrain  = ecs.import.interface "mod.terrain|iterrain"
local iprinter= ecs.import.interface "mod.printer|iprinter"
local printer_percent = 1.0
local printer_eid
local istonemountain= ecs.import.interface "mod.stonemountain|istonemountain"
local itp = ecs.import.interface "mod.translucent_plane|itranslucent_plane"
local S = ecs.system "init_system"

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local function create_instance(prefab, on_ready)
    local p = ecs.create_instance(prefab)
    p.on_ready = on_ready
    world:create_object(p)
end

function S.init()
    --ecs.create_instance "/pkg/vaststars.mod.test/assets/skybox.prefab"
    local p = ecs.create_instance  "/pkg/vaststars.mod.test/assets/light_directional.prefab"
    p.on_ready = function (e)
        local pid = e.tag["*"][1]
        local le<close> = w:entity(pid)
        iom.set_direction(le, math3d.vector(0.2664446532726288, -0.25660401582717896, 0.14578714966773987, 0.9175552725791931))
    end
    world:create_object(p)
end

local function create_mark()
    local t = {}
    local x, y = 0, 0
    for _, shape in ipairs({"I", "L", "T", "U", "X", "O"}) do
        y = y + 2
        x = 0
        for rtype = 1, 2 do
            for _, dir in ipairs({"N", "E", "S", "W"}) do
                x = x + 2
                --
                t[#t+1] = {
                    x = x, y = y,
                    layers = {
                        mark = {type  = rtype, shape = shape, dir = dir}
                    }
                }
            end
        end
    end
    t[#t+1] =     {
        x = 0, y = 0,
        layers =
        {
            road =
            {
                type  = "3",
                shape = "I",
                dir   = "N"
            }
        }
    }
    t[#t+1] =     {
        x = 1, y = 0,
        layers =
        {
            road =
            {
                type  = "3",
                shape = "I",
                dir   = "N"
            }
        }
    }
    iterrain.create_roadnet_entity(t)
end

function S.init_world()
    local mq = w:first("main_queue camera_ref:in")
    local eyepos = math3d.vector(0, 8, -8)
    local camera_ref<close> = w:entity(mq.camera_ref)
    iom.set_position(camera_ref, eyepos)
    local dir = math3d.normalize(math3d.sub(mc.ZERO_PT, eyepos))
    iom.set_direction(camera_ref, dir)

    iterrain.gen_terrain_field(256, 256, 128)
    --istonemountain.create_sm_entity(0.8, 256, 256, 128)
    --create_mark()

     printer_eid = ecs.create_entity {
        policy = {
            "ant.render|render",
            "ant.general|name",
            "mod.printer|printer",
        },
        data = {
            name        = "printer_test",
            scene  = {s = 0.5, t = {0, 0, 0}},
            material    = "/pkg/mod.printer/assets/printer.material",
            visible_state = "main_view",
            mesh        = "/pkg/vaststars.mod.test/assets/chimney-1.glb|meshes/Plane_P1.meshbin",
            render_layer= "postprocess_obj",
            printer = {
                percent  = printer_percent
            }
        },
    } 
end

local kb_mb = world:sub{"keyboard"}

local eid_table = {}
function S:data_changed()
    for _, key, press in kb_mb:unpack() do
        if key == "M" and press == 0 then
            printer_percent = printer_percent + 0.1
            if printer_percent >= 1.0 then
                printer_percent = 0.0
            end
            iprinter.update_printer_percent(printer_eid, printer_percent)
        elseif key == "J" and press == 0 then
            local rect_table = {
                [1] = {x = -1, z = -1, w = 3, h = 3},
                [2] = {x = 3, z = 3, w = 5, h = 5},
                [3] = {x = 1, z = 1, w = 4, h = 4}
            }
            local color_table = {
                {1.0, 0.0, 0.0, 1.0},
                {0.0, 1.0, 0.0, 1.0},
                {0.0, 0.0, 1.0, 1.0}
            }
            eid_table = itp.create_translucent_plane(rect_table, color_table, "translucent")
        elseif key =="K" and press == 0 then
            itp.remove_translucent_plane(eid_table)
        end
    end
end

function S:camera_usage()
 
end
