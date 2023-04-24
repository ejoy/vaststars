local hierarchy = require "hierarchy"
local animation = hierarchy.animation
local skeleton = hierarchy.skeleton
local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant

local function make_track(slots, slot_names, tickcount)
    local mat = {}
    local raw_animation = animation.new_raw_animation()
    local skl = skeleton.build({{name = "root", s = mc.T_ONE, r = mc.T_IDENTITY_QUAT, t = mc.T_ZERO}})
    local len = #slot_names
    assert(len > 1)
    raw_animation:setup(skl, len - 1)
    for idx, slot_name in ipairs(slot_names) do
        raw_animation:push_prekey(
            "root",
            idx - 1,
            slots[slot_name].scene.s,
            slots[slot_name].scene.r,
            slots[slot_name].scene.t
        )
    end
    local ani = raw_animation:build()
    local poseresult = animation.new_pose_result(#skl)
    poseresult:setup(skl)

    local ratio = 0
    local step = 1 / tickcount

    while ratio <= 1.0 do
        poseresult:do_sample(animation.new_sampling_context(1), ani, ratio, 0)
        poseresult:fetch_result()
        mat[#mat+1] = math3d.ref(poseresult:joint(1))
        ratio = ratio + step
    end
    return mat
end

return {
    make_track = make_track,
}