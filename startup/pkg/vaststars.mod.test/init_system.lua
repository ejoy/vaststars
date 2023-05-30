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
local iprinter = ecs.import.interface "mod.printer|iprinter"
local printer_percent = 1.0
local printer_eid
local istonemountain = ecs.import.interface "mod.stonemountain|istonemountain"
local itp = ecs.import.interface "mod.translucent_plane|itranslucent_plane"
local ibillboard = ecs.import.interface "mod.billboard|ibillboard"
local iroad = ecs.import.interface "mod.road|iroad"
local S = ecs.system "init_system"

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

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

local create_list = {}
local update_list = {}
local delete_list = {}
function S.init_world()
    local mq = w:first("main_queue camera_ref:in")
    local eyepos = math3d.vector(0, 100, -50)
    local camera_ref<close> = w:entity(mq.camera_ref)
    iom.set_position(camera_ref, eyepos)
    local dir = math3d.normalize(math3d.sub(mc.ZERO_PT, eyepos))
    iom.set_direction(camera_ref, dir)

    iterrain.gen_terrain_field(256, 256, 128)
--[[      local x, y = 0, 0
    for _, shape in ipairs({"I", "L", "T", "U", "X", "O"}) do
        y = y + 2
        x = 0
        for rtype = 1, 2 do
            for _, dir in ipairs({"N", "E", "S", "W"}) do
                x = x + 2
                
                create_list[#create_list+1] = {
                    x = x, y = y,
                    layers = {
                        road = {type  = rtype, shape = shape, dir = dir}
                    }
                }
                update_list[#update_list+1] = {
                    x = x, y = y,
                    layers = {
                        mark = {type  = 1, shape = shape, dir = dir}
                    }
                }
                delete_list[#delete_list+1] = {
                    x = x, y = y,
                }
            end
        end
    end
    iroad.update_roadnet_group(1000, create_list)   ]]
 
--[[     local density = 0.5
    local width, height, offset, UNIT = 256, 256, 128, 10
    local scale_table = {
        big = 1.0,
        middle = 0.6,
        small = 0.01
    }
      local stone_area = {
        {x = 0, z = 0},
    }
     local open_area = {
        {x = -128, z = 128, w = 256, h = 256}
    }   
    istonemountain.create_sm_entity(density, width, height, offset, UNIT, scale_table, stone_area, open_area)     ]] 
    --create_mark()

--[[      printer_eid = ecs.create_entity {
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
    } ]]

--[[       create_instance("/pkg/vaststars.mod.test/assets/miner-1.glb|mesh.prefab",
    function (e)
        local ee<close> = w:entity(e.tag['*'][1])
        iom.set_scale(ee, 1)
        iom.set_position(ee, math3d.vector(200, 0, 0, 1))
    end)  ]]

--[[     create_instance("/pkg/vaststars.mod.test/assets/miner-1.glb|mesh.prefab",
    function (e)
        local ee<close> = w:entity(e.tag['*'][1])
        iom.set_scale(ee, 1)
        iom.set_position(ee, math3d.vector(0, 0, 0, 1))
    end)   ]]
end

local kb_mb = world:sub{"keyboard"}

local tf_table = {}
local remove_id
function S:data_changed()
    for _, key, press in kb_mb:unpack() do
        if key == "J" and press == 0 then
            local width, height = 20, 20
            iroad.set_args(width, height)
            create_list = {
                [1] = {
                    layers = {
                        road = {type  = 1, shape = "I", dir = "N"},
                        mark = {type  = 1, shape = "I", dir = "N"}
                    },
                    x = 0, y = 0 --leftbottom
                }
            }
            iroad.update_roadnet_group(1000, create_list)
--[[              local x, y = -5, -5
            for _, shape in ipairs({"I", "L", "T", "U", "X", "O"}) do
                y = y + 2
                x = 0
                for rtype = 1, 2 do
                    for _, dir in ipairs({"N", "E", "S", "W"}) do
                        x = x + 2
                        
                        create_list[#create_list+1] = {
                            x = x, y = y,
                            layers = {
                                road = {type  = rtype, shape = shape, dir = dir}
                            }
                        }
                        update_list[#update_list+1] = {
                            x = x, y = y,
                            layers = {
                                mark = {type  = 1, shape = shape, dir = dir}
                            }
                        }
                        delete_list[#delete_list+1] = {
                            x = x, y = y,
                        }
                    end
                end
            end ]]
        
--[[             create_list[#create_list+1] = {
                x = 1, y = 1,
                layers =
                {
                    road =
                    {
                        type  = "3",
                        shape = "I",
                        dir   = "N"                
                    },
                    mark =
                    {
                        type  = "1",
                        shape = "L",
                        dir   = "N"
                    }
                }
            } ]]
        elseif key == "K" and press == 0 then

            iroad.update_roadnet_group(1000, {})
        elseif key == "L" and press == 0 then

            local rect = {x = 5, z = 5, w = 5, h = 5}
            local color = {1, 1, 0, 0.5}
            remove_id = itp.create_translucent_plane(rect, color, "translucent")

--[[              itp.remove_translucent_plane(remove_id)
            remove_id = itp.create_translucent_plane(rect, color, "translucent")   ]]
        elseif key == "N" and press == 0 then
            local rect = {x = 4, z = 4, w = 6, h = 6}
            local color = {1, 0, 0, 0.5}
            remove_id = itp.create_translucent_plane(rect, color, "translucent")  
        elseif key == "M" and press == 0 then
            local rect = {x = 5, z = 5, w = 5, h = 5}
            local color = {1, 1, 0, 0.5}
            itp.remove_translucent_plane(remove_id)
            remove_id = itp.create_translucent_plane(rect, color, "translucent")
        elseif key == "T" and press == 0 then
            local rect = {x = -10, z = 10, w = 20, h = 20}
            itp.create_translucent_plane(rect, {1, 0, 0, 1}, "opacity")  
            local area = istonemountain.get_sm_rect_intersect(rect)
            for k, v in pairs(area) do
                itp.create_translucent_plane(v, {1, 1, 0, 1}, "opacity") 
            end
            local t = 1
        end
    end
end

function S:camera_usage()
 
end
