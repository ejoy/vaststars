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
M.DuskTick   = 100 * M.UPS;
M.NightTick  =  50 * M.UPS + M.DuskTick;
M.DawnTick   = 100 * M.UPS + M.NightTick;
M.DayTick    = 250 * M.UPS + M.DawnTick;

return M