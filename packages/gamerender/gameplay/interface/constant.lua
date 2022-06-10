local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc, mu = mathpkg.constant, mathpkg.util

local M = {}
M.ALL_DIR = {'N', 'S', 'W', 'E'}
M.DEFAULT_DIR = 'N'
M.ROTATORS = {
    N = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(0)}),
    E = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    S = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    W = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

return M