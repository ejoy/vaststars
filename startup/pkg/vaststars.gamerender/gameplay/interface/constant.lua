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
M.UPS = 50

return M