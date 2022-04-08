local ecs = ...
local world = ecs.world
local ltask = require "ltask"
local ltask_now = ltask.now
local create_queue = require "utility.queue"
local frames = create_queue()

local function gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local update_fps do
    local maxfps = 60
    local last_print_time = 0
    local maxtimecachedframe <const> = 1000

    function update_fps()
        local current = gettime()
        frames:push(current)

        if current - last_print_time > maxtimecachedframe then
            while frames:size() > 0 and current - frames:first() > maxtimecachedframe do
                frames:pop()
            end

            local printtext = ("FPS: %.03f / %d"):format(frames:size(), maxfps)
            world:pub {"ui_message", "print_fps", printtext}
            last_print_time = current
        end
    end
end
return update_fps