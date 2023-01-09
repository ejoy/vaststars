--[[
                        North:(y - 1):(0, -1)
West:(x - 1):(-1, 0)                             East:(x + 1):(1, 0)
                        South:(y + 1):(0, 1)
--]]

local vector2 = {}
vector2.DOWN  = {0,  1}
vector2.UP    = {0, -1}
vector2.LEFT  = {-1, 0}
vector2.RIGHT = {1,  0}
vector2.UP_LEFT    = {-1, -1}
vector2.DOWN_LEFT  = {-1,  1}
vector2.UP_RIGHT   = {1,  -1}
vector2.DOWN_RIGHT = {1,   1}
return vector2