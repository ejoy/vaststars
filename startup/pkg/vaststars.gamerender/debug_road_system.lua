local ecs = ...
local world = ecs.world
local w = world.w

local debug_road_sys = ecs.system "debug_road_system"
local kb_mb = world:sub{"keyboard"}
local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"

local terrain = ecs.require "terrain"

local iroadnet = ecs.require "roadnet"
local CONSTANT = ecs.require "gameplay.interface.constant"

local icamera_controller = ecs.require "engine.system.camera_controller"
local mc = import_package "ant.math".constant

local ROW_SPACING, COL_SPACING = 2, 2 -- unit per tile

local function print_camera_position()
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce<close> = world:entity(mq.camera_ref, "scene:update")
    log.info(math3d.tostring(iom.get_position(ce)))
end

-- world coordinate x
-- world coordinate y
-- layers: road/mark/road and mark
--         road: type(1~3) shape(I L T U X O) dir(N E S W)
--[[
                    1. 建造完
                    2. 删除未确认
                    3. 建造未确认
--]]
--         mark: type(1~2) shape(U I O) dir(N E S W)
--[[
                    1. 指示器 - 删除
                    2. 指示器 - 建造
--]]

local SHAPE_TYPES<const> = {"I", "L", "T", "U", "X", "O"}
local SHAPE_DIRECTIONS<const> = {"N", "E", "S", "W"}
local INDICATOR_STATES<const> = {"valid", "invalid"}
local ROAD_STATES<const> = {"normal", "remove", "modify"}

local START_X<const>, START_Y<const> = 118, 118--CONSTANT.MAP_OFFSET, CONSTANT.MAP_OFFSET

local function create_road()
    local x, y = START_X, START_Y
    for _, shape in ipairs(SHAPE_TYPES) do
        y = y + ROW_SPACING
        x = START_X
        for _, state in ipairs(ROAD_STATES) do
            for _, dir in ipairs(SHAPE_DIRECTIONS) do
                iroadnet:set("road", state, x, y, shape, dir)
                x = x + COL_SPACING
            end
        end
    end

    -- iroadnet:set("road", "valid", START_X+0, START_Y, "L", "N")
    -- iroadnet:set("road", "valid", START_X+3, START_Y, "L", "E")
    -- iroadnet:set("road", "valid", START_X+6, START_Y, "L", "S")
    -- iroadnet:set("road", "valid", START_X+9, START_Y, "L", "W")
    iroadnet:flush()
end

local function create_simple_road()
    iroadnet:update{
        [terrain:get_group_id(0, 0)] = {
            x=0, y=0,
            pos = iroadnet:cvtcoord2pos(0, 0),
            road = {
                state = "valid",
                shape = "O",
                dir = "N",
            }
        }
    }
end

local function create_mark()
    local x, y = START_X, START_Y
    for _, shape in ipairs(SHAPE_TYPES) do
        y = y + ROW_SPACING
        x = START_X
        for _, state in ipairs(INDICATOR_STATES) do
            for _, dir in ipairs(SHAPE_DIRECTIONS) do
                iroadnet:set("indicator", state, x, y, shape, dir)
                x = x + COL_SPACING
            end
        end
    end
    iroadnet:flush()
end

local function create_road_mark()
    local x, y = START_X, START_Y
    for _, shape in ipairs(SHAPE_TYPES) do
        y = y + ROW_SPACING
        x = START_X

        for _, dir in ipairs(SHAPE_DIRECTIONS) do
            for _, rstate in ipairs(ROAD_STATES) do
                iroadnet:set("road", rstate, x, y, shape, dir)
                x = x + COL_SPACING
            end
    
            for _, istate in ipairs(INDICATOR_STATES) do
                iroadnet:set("indicator", istate, x, y, shape, dir)
                x = x + COL_SPACING
            end
        end
    end
    iroadnet:flush()
end

local function move_camera()
    -- icamera_controller.set_camera_srt(
    --     mc.ONE,
    --     math3d.ref(math3d.quaternion(0.70710676908493,0.0,0.0,0.70710676908493)),
    --     math3d.ref(math3d.vector(168.09506225586,349.99993896484,117.53267669678,0.0))
    -- )
end

local DO_ONCE
function debug_road_sys:init_world()
    -- world:create_instance{
    --     prefab = "/pkg/ant.resources.binary/meshes/base/cube.glb|mesh.prefab",
    --     on_ready = function (e)
    --         local rooteid = e.tag['*'][1]
    --         local re<close> = world:entity(rooteid, "scene:update")
    --         iom.set_position(re, math3d.vector(0, 0, 0, 1))
    --         iom.set_scale(re, 10)
    --     end
    -- }

    -- local rhwi = import_package "ant.hwi"
    -- rhwi.set_debug {}

    -- local iterrain  = ecs.require "ant.landform|terrain_system"
    -- iterrain.gen_terrain_field(CONSTANT.MAP_WIDTH, CONSTANT.MAP_HEIGHT, CONSTANT.MAP_OFFSET, CONSTANT.TILE_SIZE, RENDER_LAYER.TERRAIN)
    DO_ONCE = 1
end

function debug_road_sys:ui_update()
    if DO_ONCE == 2 then
        --create_road()
        create_road_mark()
        DO_ONCE = nil
    elseif DO_ONCE == 1 then
        DO_ONCE = 2
    end

    for _, key, press in kb_mb:unpack() do
        if key == "T" and press == 0 then
            move_camera()
            create_road()
        end
        if key == "R" and press == 0 then
            move_camera()
            create_mark()
        end
        if key == "E" and press == 0 then
            move_camera()
            create_road_mark()
        end
        if key == "S" and press == 0 then
            move_camera()
            create_simple_road()
        end
        if key == "Y" and press == 0 then
            print_camera_position()
        end
    end
end
