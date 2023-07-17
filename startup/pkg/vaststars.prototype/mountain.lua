local UNIT <const> = 10
local BORDER <const> = 5
local MAP_WIDTH <const> = 256
local MAP_HEIGHT <const> = 256
local WIDTH <const> = MAP_WIDTH + BORDER * 2
local HEIGHT <const> = MAP_HEIGHT + BORDER * 2
local OFFSET <const> = WIDTH // 2
assert(OFFSET == HEIGHT // 2)

local MIN_X <const> = -BORDER + 1
local MAX_X <const> = MAP_WIDTH + BORDER
local MIN_Y <const> = -BORDER + 1
local MAX_Y <const> = MAP_HEIGHT + BORDER

density = 0.3

mountain_coords = {
    {MIN_X, MIN_Y, WIDTH, BORDER},
    {MIN_X, MIN_Y + BORDER, BORDER, HEIGHT - BORDER * 2},
    {MAX_X - BORDER + 1, MIN_Y + BORDER, BORDER, HEIGHT - BORDER * 2},
    {MIN_X, MAX_Y - BORDER + 1, WIDTH, BORDER},
    {153,101, 1, 1},
    {97,113, 1, 1},
    {92,110, 1, 1},
    {84,109, 1, 1},
    ------------------------------------
    {145,139, 2, 2},
    {146,139, 2, 2},
    {145,140, 2, 2},
    {146,140, 2, 2},
    {146,138, 2, 2},
    {145,141, 2, 2},
    {145,137, 2, 2},
    {144,140, 2, 2},
    {144,139, 2, 2},
    ------------------------------------
    {146,143, 2, 2},
    {147,143, 2, 2},
    {148,144, 2, 2},
    {149,144, 2, 2},
    {150,145, 2, 2},
    {149,145, 2, 2},
    {150,146, 2, 2},
    {149,146, 2, 2},
    ------------------------------------
    {73,159, 2, 2},
    {72,159, 2, 2},
    {74,160, 2, 2},
    {74,161, 2, 2},
    {73,160, 2, 2},
    {73,161, 2, 2},
    {75,159, 2, 2},
    {75,160, 2, 2},
    {74,159, 2, 2},
    {74,158, 2, 2},
}

-- the first two numbers represent the x and y coordinates of the upper-left corner of the rectangle
-- the last two numbers represent the width and height of the rectangle
excluded_rects = {
    {29, 89, 187, 116},
}
