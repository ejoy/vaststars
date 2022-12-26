local ecs = ...
local world = ecs.world
local w = world.w

local iroad = ecs.require "engine.road"
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"

local WIDTH <const> = 256 -- coordinate value range: [0, WIDTH - 1]
local HEIGHT <const> = 256 -- coordinate value range: [0, HEIGHT - 1]
local NIL <const> = setmetatable({} , { __tostring = function() return "NULL" end })	-- nil
local MASK_BITS <const> = 2
local MASK = 0
for i = 0, MASK_BITS - 1 do
    MASK = MASK | (1 << i)
end

-- logic axis
-- ┌──►x
-- │
-- │
-- ▼
-- y

-- render axis
-- z
-- ▲
-- │
-- │
-- └──►x

local mt = {
	__index = function(t, k)
		return t.__lastversion[k]
	end,
    __newindex = function(t, k, v)
        t.__change_keys[k] = true
        t.__lastversion[k] = v
    end,
    __pairs = function (t)
        return function(t, key)
            return next(t.__lastversion, key)
        end, t
    end,
}

local function new(o)
    local t = {}
    t.__change_keys = {}
	t.__lastversion = o or {}
    return setmetatable(t, mt)
end

---------------------------------------------------------
local function _make_value(flow_type, mask)
    return (flow_type << 8) | mask -- high 8 bits for flow type, low 8 bits for mask
end

local function _get_flow_type(value)
    return value >> 8
end

local function _get_mask(value)
    return value & 0xFF
end

-- dir: [0, 4)
local function _get_dir_state(value, dir)
    local mask = _get_mask(value)
    return (mask >> (dir * MASK_BITS)) & MASK
end

local function _set_dir_state(mask, dir, value)
    local shift = dir * MASK_BITS
    return (mask & ~(MASK << shift)) | (value << shift)
end

-- convert to gameplay mask
local function _convert_mask(m)
    local mask = 0
    for i = 0, 3 do
        local v = _get_dir_state(m, i)
        if v == 1 then
            mask = mask | (1 << i)
        end
    end
    return mask
end

---------------------------------------------------------

local function _pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function _unpack(k)
    return k & 0xFF, k>>8
end

local function _convert_coord(x, y)
    return x, WIDTH - y - 1
end

local _render_struct, _render_struct_array, get_prototype_name, get_road_mask; do
    local mapping = {
        W = 0, -- left
        N = 1, -- top
        E = 2, -- right
        S = 3, -- bottom
    }

    local mt = {}
    function mt:__index(k)
        self[k] = {}
        return self[k]
    end
    local cache = setmetatable({}, mt)
    local cache_value = setmetatable({}, mt) -- TODO: remove this cache
    local cache_prototype = setmetatable({}, mt) -- TODO: remove this cache

    for _, pt in pairs(iprototype.each_maintype("entity", "road")) do
        for _, dir in ipairs(pt.flow_direction) do
            local mask = 0
            for _, conn in ipairs(pt.crossing.connections) do
                local d = assert(mapping[iprototype.rotate_dir(conn.position[3], dir)])
                local value = 0
                if conn.roadside then
                    value = 2
                else
                    value = 1
                end
                mask = _set_dir_state(mask, d, value)
            end

            local value = _make_value(0, mask)

            cache[value] = {pt.track, dir}
            cache_value[0][mask] = {pt.name, dir}
            cache_prototype[pt.name][dir] = {pt.flow_type, mask}
        end
    end

    function get_road_mask(prototype_name, dir)
        local t = cache_prototype[prototype_name][dir]
        if t then
            return t[1], t[2]
        end
    end

    function get_prototype_name(flow_type, mask) -- TODO: remove this function
        local t = cache_value[flow_type][mask]
        if t then
            return t[1], t[2]
        end
    end

    function _render_struct(key, value, state)
        local ox, oy = _unpack(key)
        local x, y = _convert_coord(ox, oy)
        local shape, dir = assert(cache[value][1]), assert(cache[value][2])
        return {x, y, shape, dir}
    end

    function _render_struct_array(t, state)
        local result = {}
        for k, v in pairs(t) do
            result[#result + 1] = _render_struct(k, v, state)
        end
        return result
    end
end

-- key = _pack(x, y)-- shape = 'I' | 'L' | 'T' | 'X' | 'O'
-- direction = 'N' | 'E' | 'S' | 'W'
local render_cache = new() -- = {[key] = {shape, dir}}

-- state = "constructing" / "confirm" / "gameplay" 
local gameplay_cache = new() -- = { [key] = mask, ... }
local confirm_cache = new() -- same as gameplay_cache, but only contains the road in confirm state
local constructing_cache = new() -- same as gameplay_cache, but only contains the road in constructing state

local function init(t)
    t = t or {}
    gameplay_cache = new(t)

    iroad.init(WIDTH, HEIGHT, WIDTH//2, HEIGHT//2, _render_struct_array(t))

    --
    local gameplay_world = gameplay_core.get_world()
    local roadnet = gameplay_world.roadnet

    local t = {}
    for k, v in pairs(gameplay_cache) do
        t[k] = _convert_mask(_get_mask(v))
    end
    roadnet:load_map(t)
end

local function world_update()
    if next(constructing_cache.__change_keys) then
        for k in pairs(constructing_cache.__change_keys) do
            if constructing_cache[k] == NIL then
                render_cache[k] = nil
            else
                render_cache[k] = _render_struct(k, constructing_cache[k], "constructing")
            end
        end
        constructing_cache.__change_keys = {}
        return
    end

    if next(confirm_cache.__change_keys) then
        for k in pairs(confirm_cache.__change_keys) do
            if confirm_cache[k] == NIL then
                render_cache[k] = nil
            else
                render_cache[k] = _render_struct(k, confirm_cache[k], "confirm")
            end
        end
        confirm_cache.__change_keys = {}
        return
    end

    if next(gameplay_cache.__change_keys) then
        for k in pairs(gameplay_cache.__change_keys) do
            if not gameplay_cache[k] then
                render_cache[k] = nil
            else
                render_cache[k] = _render_struct(k, gameplay_cache[k], "gameplay")
            end
        end
        gameplay_cache.__change_keys = {}
        return
    end
end

local function render_update()
    local update = {}
    local delete = {}

    for key in pairs(render_cache.__change_keys) do
        if render_cache[key] then
            local v = render_cache[key]
            update[#update+1] = v
        else
            delete[#delete+1] = {_convert_coord(_unpack(key))}
        end
    end
    render_cache.__change_keys = {}

    if next(update) then
        iroad.update(update)
    end

    if next(delete) then
        iroad.del(delete)
    end
end

local function editor_set(x, y, flow_type, mask)
    local k = _pack(x, y)
    if mask == nil then
        constructing_cache[k] = NIL
    else
        constructing_cache[k] = _make_value(0, mask)
    end
end

local function _editor_get(x, y)
    local k = _pack(x, y)
    if constructing_cache[k] then
        if constructing_cache[k] == NIL then
            return
        else
            return constructing_cache[k]
        end
    end

    if confirm_cache[k] then
        if confirm_cache[k] == NIL then
            return
        else
            return confirm_cache[k]
        end
    end

    return gameplay_cache[k]
end

local function editor_get(x, y)
    local value = _editor_get(x, y)
    if value then
        return _get_flow_type(value), _get_mask(value)
    end
end

local function editor_confirm()
    for k, v in pairs(constructing_cache) do
        confirm_cache[k] = v
    end
    constructing_cache = new()
end

local function editor_build()
    for k, v in pairs(confirm_cache) do
        if v == NIL then
            gameplay_cache[k] = nil
        else
            gameplay_cache[k] = v
        end
    end
    confirm_cache = new()

    --
    local gameplay_world = gameplay_core.get_world()
    local roadnet = gameplay_world.roadnet

    local t = {}
    for k, v in pairs(gameplay_cache) do
        t[k] = _convert_mask(_get_mask(v))
    end
    roadnet:load_map(t)
end

local function editor_clear_constructing()
    local changed = {}
    for k in pairs(constructing_cache) do
        changed[k] = true
    end
    constructing_cache = new()

    for k in pairs(changed) do
        if not confirm_cache[k] then
            if not gameplay_cache[k] then
                render_cache[k] = nil
            else
                render_cache[k] = _render_struct(k, gameplay_cache[k], "gameplay")
            end
            goto continue
        end

        if confirm_cache[k] == NIL then
            render_cache[k] = nil
            goto continue
        end

        render_cache[k] = _render_struct(k, confirm_cache[k], "confirm")
        ::continue::
    end
end

local function editor_clear_confirm()
    local changed = {}
    for k in pairs(confirm_cache) do
        changed[k] = true
    end
    confirm_cache = new()

    for k in pairs(changed) do
        if not gameplay_cache[k] then
            render_cache[k] = nil
        else
            render_cache[k] = _render_struct(k, gameplay_cache[k], "gameplay")
        end
    end
end

return {
    init = init,
    world_update = world_update,
    render_update = render_update,
    editor_set = editor_set,
    editor_get = editor_get,
    editor_confirm = editor_confirm,
    editor_build = editor_build,
    editor_clear_constructing = editor_clear_constructing,
    editor_clear_confirm = editor_clear_confirm,
    get_prototype_name = get_prototype_name,
    get_road_mask = get_road_mask,
}