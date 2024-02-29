local TRANSFORM_DELTA <const> = 16.5
local BUTTON_POSITIONS = {}
for i = 1, 5 do
    BUTTON_POSITIONS[i] = {
        outer_transform = ("rotate(%sdeg)"):format(-TRANSFORM_DELTA * (i - 1)),
        inner_transform = ("rotate(%sdeg)"):format(TRANSFORM_DELTA * (i - 1)),
    }
end

local OFFSETS <const> = {
    [1] = {
        [1] = BUTTON_POSITIONS[3],
    },
    [2] = {
        [1] = BUTTON_POSITIONS[2],
        [2] = BUTTON_POSITIONS[4],
    },
    [3] = {
        [1] = BUTTON_POSITIONS[2],
        [2] = BUTTON_POSITIONS[3],
        [3] = BUTTON_POSITIONS[4],
    },
    [4] = {
        [1] = BUTTON_POSITIONS[2],
        [2] = BUTTON_POSITIONS[3],
        [3] = BUTTON_POSITIONS[4],
        [4] = BUTTON_POSITIONS[5],
    },
    [5] = {
        [1] = BUTTON_POSITIONS[1],
        [2] = BUTTON_POSITIONS[2],
        [3] = BUTTON_POSITIONS[3],
        [4] = BUTTON_POSITIONS[4],
        [5] = BUTTON_POSITIONS[5],
    }
}

local function set_button_offset(buttons)
    -- print("#buttons", #buttons)
    if #buttons > 0 then
        local offsets = OFFSETS[#buttons] or error(("(%s)"):format(#buttons))
        for i = 1, #buttons do
            for k, v in pairs(offsets[i]) do
                buttons[i][k] = v
            end
        end
    end
end

return {
    set_button_offset = set_button_offset,
}