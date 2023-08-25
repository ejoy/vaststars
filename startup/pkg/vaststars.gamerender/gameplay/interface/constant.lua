local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc = mathpkg.constant

local M = {}
M.ALL_DIR = {'N', 'S', 'W', 'E'}
M.ALL_DIR_NUM = {0, 1, 2, 3}
M.DEFAULT_DIR = 'N'
M.ROTATORS = {
    N = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(0)})   )),
    E = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(90)})  )),
    S = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(180)}) )),
    W = math3d.constant( math3d.totable(math3d.quaternion({axis=mc.YAXIS, r=math.rad(270)}) )),
}
M.UPS = 30
M.DELTA_TIME = 1000 / M.UPS

M.DuskTick   = 100 * M.UPS;
M.NightTick  =  50 * M.UPS + M.DuskTick;
M.DawnTick   = 100 * M.UPS + M.NightTick;
M.DayTick    = 250 * M.UPS + M.DawnTick;

M.CHANGED_FLAG_ASSEMBLING = 1 << 0
M.CHANGED_FLAG_BUILDING   = 1 << 1
M.CHANGED_FLAG_CHIMNEY    = 1 << 2
M.CHANGED_FLAG_ROADNET    = 1 << 3
M.CHANGED_FLAG_FLUIDFLOW  = 1 << 4
M.CHANGED_FLAG_ALL = M.CHANGED_FLAG_ASSEMBLING | M.CHANGED_FLAG_BUILDING | M.CHANGED_FLAG_CHIMNEY | M.CHANGED_FLAG_ROADNET | M.CHANGED_FLAG_FLUIDFLOW

return M