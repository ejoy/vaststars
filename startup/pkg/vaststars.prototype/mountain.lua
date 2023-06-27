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
    {73,159, 1, 1},
    {153,101, 1, 1},
    {97,113, 1, 1},
    {92,110, 1, 1},
    {84,109, 1, 1},
    {145,139, 1, 1},
    {150,145, 1, 1},
}

-- the first two numbers represent the x and y coordinates of the upper-left corner of the rectangle
-- the last two numbers represent the width and height of the rectangle
excluded_rects = {
    {29, 89, 187, 116},
}
