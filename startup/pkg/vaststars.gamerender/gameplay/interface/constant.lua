local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc = mathpkg.constant

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 0, -- TODO: remove this
    [1] = 1,
    [2] = 2,
    [3] = 3,
}

local M = {}
M.MAP_WIDTH_COUNT = 256
M.MAP_HEIGHT_COUNT = 256
M.TILE_SIZE = 10
M.ROAD_COUNT = 2
M.ROAD_WIDTH_COUNT = M.ROAD_COUNT
M.ROAD_HEIGHT_COUNT = M.ROAD_COUNT
M.ROAD_WIDTH_SIZE = M.TILE_SIZE * M.ROAD_WIDTH_COUNT
M.ROAD_HEIGHT_SIZE = M.TILE_SIZE * M.ROAD_HEIGHT_COUNT

M.ALL_DIR = {'N', 'S', 'W', 'E'}
M.ALL_DIR_NUM = {0, 1, 2, 3}
M.DEFAULT_DIR = 'N'
M.DIRECTION = DIRECTION
M.DIR_MOVE_DELTA = {
    ['N'] = {x = 0,  y = -1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = 1},
    ['W'] = {x = -1, y = 0},
    [DIRECTION.N] = {x = 0,  y = -1},
    [DIRECTION.E] = {x = 1,  y = 0},
    [DIRECTION.S] = {x = 0,  y = 1},
    [DIRECTION.W] = {x = -1, y = 0},
}
M.ROTATORS = {
    N = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)})   ),
    E = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)})  ),
    S = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(180)}) ),
    W = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(270)}) ),

    [DIRECTION.N] = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)})   ), -- TODO: remove
    [DIRECTION.E] = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)})  ),
    [DIRECTION.S] = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(180)}) ),
    [DIRECTION.W] = math3d.constant("quat", math3d.quaternion({axis=mc.YAXIS, r=math.rad(270)}) ),
}
M.FPS = 30
M.UPS = 30
M.DELTA_TIME = 1000 / M.UPS

M.DuskTick   = 100 * M.UPS
M.NightTick  =  50 * M.UPS + M.DuskTick
M.DawnTick   = 100 * M.UPS + M.NightTick
M.DayTick    = 250 * M.UPS + M.DawnTick

M.CHANGED_FLAG_ASSEMBLING = 1 << 0
M.CHANGED_FLAG_BUILDING   = 1 << 1
M.CHANGED_FLAG_CHIMNEY    = 1 << 2
M.CHANGED_FLAG_ROADNET    = 1 << 3
M.CHANGED_FLAG_FLUIDFLOW  = 1 << 4
M.CHANGED_FLAG_STATION    = 1 << 5
M.CHANGED_FLAG_DEPOT      = 1 << 6
M.CHANGED_FLAG_ALL = M.CHANGED_FLAG_ASSEMBLING | M.CHANGED_FLAG_BUILDING | M.CHANGED_FLAG_CHIMNEY | M.CHANGED_FLAG_ROADNET | M.CHANGED_FLAG_FLUIDFLOW 
    | M.CHANGED_FLAG_STATION | M.CHANGED_FLAG_DEPOT

-- fluid & id: corresponds to the field name in the e.fluidboxes
-- classify: represents the category of fluidboxes in the configuration, either "input" or "output"
-- index: represents the index in the input or output array in the configuration
M.IN_FLUIDBOXES = {
    {name = "in1", fluid = "in1_fluid", id = "in1_id", classify = "input", index = 1},
    {name = "in2", fluid = "in2_fluid", id = "in2_id", classify = "input", index = 2},
    {name = "in3", fluid = "in3_fluid", id = "in3_id", classify = "input", index = 3},
    {name = "in4", fluid = "in4_fluid", id = "in4_id", classify = "input", index = 4},
}
M.OUT_FLUIDBOXES = {
    {name = "out1", fluid = "out1_fluid", id = "out1_id", classify = "output", index = 1},
    {name = "out2", fluid = "out2_fluid", id = "out2_id", classify = "output", index = 2},
    {name = "out3", fluid = "out3_fluid", id = "out3_id", classify = "output", index = 3},
}

M.FLUIDBOXES = {}
table.move(M.IN_FLUIDBOXES, 1, #M.IN_FLUIDBOXES, 1, M.FLUIDBOXES)
table.move(M.OUT_FLUIDBOXES, 1, #M.OUT_FLUIDBOXES, #M.FLUIDBOXES+1, M.FLUIDBOXES)

M.GRID_POSITION_OFFSET = math3d.constant("v4", {0, 0.2, 0, 0.0})

M.BUILDING_EFK_SCALE = {
    ["1x1"] = {4, 4, 4},
    ["1x2"] = {5, 5, 5},
    ["2x1"] = {5, 5, 5},
    ["2x2"] = {5, 5, 5},
    ["3x2"] = {7, 7, 7},
    ["3x3"] = {7, 7, 7},
    ["3x5"] = {10, 10, 10},
    ["4x2"] = {7, 7, 7},
    ["4x4"] = {10, 10, 10},
    ["4x6"] = {12, 12, 12},
    ["5x3"] = {10, 10, 10},
    ["5x5"] = {12, 12, 12},
    ["6x6"] = {12, 12, 12},
}

return M