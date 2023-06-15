local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc = mathpkg.constant

local M = {}
M.ALL_DIR = {'N', 'S', 'W', 'E'}
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

M.ROADNET_MASK_ENDPOINT     = 1 << 4
M.ROADNET_MASK_NOLEFTTURN   = 1 << 5
M.ROADNET_MASK_ROADNET_ONLY = 1 << 6
M.ROADNET_MASK_NOUTURN      = 1 << 7

M.DIRTY_ALL = 1 << 1
M.DIRTY_BUILDING = 1 << 2
M.DIRTY_FLUIDFLOW = 1 << 3
M.DIRTY_ROADNET = 1 << 4
M.DIRTY_STATION = 1 << 5
M.DIRTY_CHEST = 1 << 6
M.DIRTY_ASSEMBLING = 1 << 7

return M