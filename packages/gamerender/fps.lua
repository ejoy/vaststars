local ecs = ...
local world = ecs.world
local ltask = require "ltask"
local ltask_now = ltask.now
local create_queue = require "utility.queue"
local frames = create_queue()
local bgfx = require "bgfx"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local update_fps do
    local maxfps = 60
    local last_print_time = 0
    local max_frame_cache_time <const> = 10000
    local print_time <const> = 1000

    function update_fps()
        local current = gettime()
        frames:push(current)

        while frames:size() > 0 and current - frames:get_head() > max_frame_cache_time do
            frames:pop()
        end

        if current - last_print_time > print_time then
            local printtext = ("FPS: %.03f / %d"):format(frames:size() / 10, maxfps)
            iui.set_datamodel("construct.rml", "fps_text", printtext)

            local bgfxstat = bgfx.get_stats "sdcpnmtv"
            iui.set_datamodel("construct.rml", "drawcall_text", ("DrawCall: %d\nTriangle: %d\nTexture: %d\ncpu(ms): %f\ngpu(ms): %f\nfps: %d"):format(
                bgfxstat.numDraw, bgfxstat.numTriList, bgfxstat.numTextures, bgfxstat.cpu, bgfxstat.gpu, bgfxstat.fps))
            last_print_time = current
        end
    end
end
return update_fps