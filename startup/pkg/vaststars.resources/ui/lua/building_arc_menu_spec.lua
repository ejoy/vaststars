local t = {}

local ICON_POS <const> = {
    [1] = {
        {top = "15.00vmin", left = "2vmin"},
    },
    [2] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
    [3] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "-2vmin", left = "35vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
    [4] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "-2vmin", left = "35vmin"},
        {top = "3.00vmin", left = "53.48vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
    [5] = {
        {top = "15.00vmin", left = "2vmin"},
        {top = "3.00vmin", left = "16.62vmin"},
        {top = "-2vmin", left = "35vmin"},
        {top = "3.00vmin", left = "53.48vmin"},
        {top = "15.00vmin", left = "69.34vmin"},
    },
}

local ICON_POS1 <const> = {
    [1] = {
        {top = "15.00vmin", left = "69.34vmin"},
    },
}

-- t["机身残骸"] = function (start, default)
--     start.buttons = {}
--     if start.test then
--         local v = setmetatable({}, {__index = default})
--         v.text = "测试"
--         v.message = "test"
--         v.background_image = "textures/construct/portal-in.texture"
--         if start.guide_progress == 10 then
--             v.animation = '0.4s linear 0s infinite alternate enlarge2'
--         end
--         start.buttons[#start.buttons + 1] = v
--     end

--     return ICON_POS1
-- end

return t