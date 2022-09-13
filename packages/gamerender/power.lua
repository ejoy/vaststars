local ecs   = ...
local world = ecs.world
local w     = world.w
local math3d    = require "math3d"
local camera = ecs.require "engine.camera"
local vsobject_manager = ecs.require "vsobject_manager"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local iterrain = ecs.require "terrain"
local iline_entity = ecs.require "engine.line_entity"

local objects = require "objects"
local iobject = ecs.require "object"
local EDITOR_CACHE_NAMES = {"POWER_AREA", "CONSTRUCTED"}

local M = {}
local function set_supply_area(area, e)
    local offset_x = (e.sw - e.w)//2
    local offset_y = (e.sh - e.h)//2
    for i = e.y - offset_y, e.y + e.h + offset_y - 1 do
        for j = e.x - offset_x, e.x + e.w + offset_x - 1 do
            area[i][j] = true
        end
    end
end
local function new_network(e)
    local net = {poles = {e}, area = {}, lines = {}}
    local area = {}
    for i = 1, 256 do
        local row = {}
        for j = 1, 256 do
            row[#row + 1] = false
        end
        area[#area + 1] = row
    end
    set_supply_area(area, e)
    net.area = area
    return net
end

-- area
local function min_area_x(e) return e.x end
local function max_area_x(e) return e.x + e.w - 1 end
local function min_area_y(e) return e.y end
local function max_area_y(e) return e.y + e.h - 1 end

-- supply_area
local function min_supply_x(e) return e.x - (e.sw - e.w)//2 end
local function max_supply_x(e) return e.x + e.w + (e.sw - e.w)//2 - 1 end
local function min_supply_y(e) return e.y - (e.sh - e.h)//2 end
local function max_supply_y(e) return e.y + e.h + (e.sh - e.h)//2 - 1 end

-- supply_distance
local function min_distance_x(e) return e.x - (e.sd - (e.w + 1)//2) end
local function max_distance_x(e) return e.x + e.w - 1 + (e.sd - (e.w + 1)//2) end
local function min_distance_y(e) return e.y - (e.sd - (e.h + 1)//2) end
local function max_distance_y(e) return e.y + e.h - 1 + (e.sd - (e.h + 1)//2) end

local function contain(e, x, y)
    if x < min_distance_x(e) or x > max_distance_x(e) or y < min_distance_y(e) or y > max_distance_y(e) then
        return false
    end
    return true
end

local function connect(e0, e1)
    local min_e = e0
    local max_e = e1
    if e1.sd < e0.sd then
        min_e = e1
        max_e = e0
    end
    local r = max_e.w//2
    if max_e.w%2 == 0 then
        return contain(min_e, max_e.x + r - 1, max_e.y + r - 1)
            or contain(min_e, max_e.x + r - 1, max_e.y + r)
            or contain(min_e, max_e.x + r, max_e.y + r - 1)
            or contain(min_e, max_e.x + r, max_e.y + r)
    else
        return contain(min_e, max_e.x + r, max_e.y + r)
    end
end

local function dist_sqr(pole1, pole2)
    local pos1 = iterrain:get_position_by_coord(pole1.x, pole1.y, pole1.w, pole1.h)
    local pos2 = iterrain:get_position_by_coord(pole2.x, pole2.y, pole2.w, pole2.h)
    local dx = (pos1[1] - pos2[1])
    local dz = (pos1[3] - pos2[3])
    return dx * dx + dz * dz
end

local function shortest_conect(poles1, poles2)
    local min_connect
    local min_dist = 0xffffffff
    for _, p1 in ipairs(poles1) do
        for _, p2 in ipairs(poles2) do
            if connect(p1, p2) then
                local d = dist_sqr(p1, p2)
                if min_dist > d then
                    min_connect = {p1, p2}
                    min_dist = d
                end
            end
        end
    end
    return min_connect
end

local function area_supply_overlap(e0, e1)
    if max_area_x(e0) < min_supply_x(e1) or min_area_x(e0) > max_supply_x(e1) or max_area_y(e0) < min_supply_y(e1) or min_area_y(e0) > max_supply_y(e1) then
        return false
    end
    return true
end

local pole_height = 30
local temp_pole = {}

local function clear_temp_pole(pole, keep)
    local network = global.power_network
    if not temp_pole[pole.key] or not network then
        return
    end
    local index
    local poles
    local net_index
    for netidx, nw in ipairs(network) do
        for idx, p in ipairs(nw.poles) do
            if p and p.key == pole.key then
                poles = nw.poles
                index = idx
                net_index = netidx
                goto continue
            end
        end
    end
    ::continue::
    local line_eid = temp_pole[pole.key].line
    if line_eid then
        w:remove(line_eid)
    end
    if not keep then
        temp_pole[pole.key] = nil
    end

    if index then
        table.remove(poles, index)
        if #poles < 1 then
            table.remove(network, net_index)
        end
    end
end

local function create_line(pole1, pole2)
    local pos1
    local pos2
    if pole1.key and pole1.smooth_pos then
        local vsobject = assert(vsobject_manager:get(pole1.key))
        local p1 = math3d.totable(vsobject:get_position())
        pos1 = {p1[1], p1[2], p1[3]}
    end
    if pole2.key and pole2.smooth_pos then
        local vsobject = assert(vsobject_manager:get(pole2.key))
        local p2 = math3d.totable(vsobject:get_position())
        pos2 = {p2[1], p2[2], p2[3]}
    end
    pos1 = pos1 or iterrain:get_position_by_coord(pole1.x, pole1.y, pole1.w, pole1.h)
    pos1[2] = pos1[2] + pole_height
    pos2 = pos2 or iterrain:get_position_by_coord(pole2.x, pole2.y, pole2.w, pole2.h)
    pos2[2] = pos2[2] + pole_height
    
    local line = iline_entity.create_lines({pos1, pos2}, 80, {1.0, 0.0, 0.0, 0.7})
    return line
end

function M.merge_pole(pole, add)
    local network = global.power_network
    if pole.key and temp_pole[pole.key] then
        clear_temp_pole(pole)
    end
    local net
    local connect_pole
    for _, nw in ipairs(network) do
        local connect = shortest_conect({pole}, nw.poles)
        if connect then
            net = nw
            connect_pole = connect[2]
            goto continue
        end
    end
    ::continue::
    if net then
        net.poles[#net.poles + 1] = pole
        set_supply_area(net.area, pole)
        local line = create_line(connect_pole, pole)
        if not pole.key then
            net.lines[#net.lines + 1] = line
        else
            temp_pole[pole.key] = {line = line, pole = pole}
        end
    else
        if add then
            network[#network + 1] = new_network(pole)
        end
        if pole.key then
            temp_pole[pole.key] = {pole = pole}
        end
    end
end

local function set_network_id(w, network, e)
    local nid = 0
    for idx, net in ipairs(network) do
        local minx = min_area_x(e)
        local maxx = max_area_x(e)
        local miny = min_area_y(e)
        local maxy = max_area_y(e)
        if net.area[miny][minx] or net.area[miny][maxx] or net.area[maxy][minx] or net.area[maxy][maxx] then
            nid = idx
            break
        end
    end
    local v = w.entity[e.eid]
    if v.capacitance then
        v.capacitance.network = nid
    end
end

function M.clear_all_temp_pole()
    for _, pole in pairs(temp_pole) do
        clear_temp_pole(pole.pole, true)
    end
    temp_pole = {}
end

function M.show_supply_area()
    local network = global.power_network
    for _, nw in ipairs(network) do
        for _, pole in ipairs(nw.poles) do
            for _, object in objects:selectall("gameplay_eid", pole.eid, EDITOR_CACHE_NAMES) do
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone)
                local typeobject = iprototype.queryByName("entity", object.prototype_name)
                _object.state = ("power_pole_selected_%s"):format(typeobject.supply_area)
            end
        end
    end
end

function M.build_power_network(gw)
    M.clear_all_temp_pole()
    local powerpole = {}
    local capacitance = {}
    for v in gameplay_core.select("eid:in entity:in capacitance?in") do
        local e = v.entity
        local typeobject = iprototype.queryById(e.prototype)
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh
        if typeobject.supply_area then
            sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        end
        if v.capacitance then
            capacitance[#capacitance + 1] = {
                name = typeobject.name,
                eid = v.eid,
                x = e.x,
                y = e.y,
                w = aw,
                h = ah,
            }
        end
        if typeobject.name == "指挥中心" or typeobject.power_pole then
            powerpole[#powerpole + 1] = {
                name = typeobject.name,
                eid = v.eid,
                x = e.x,
                y = e.y,
                w = aw,
                h = ah,
                sw = tonumber(sw),
                sh = tonumber(sh),
                sd = typeobject.supply_distance
            }
        end
    end

    if global.power_network then
        for _, net in ipairs(global.power_network) do
            for _, value in ipairs(net.lines) do
                w:remove(value)
            end
        end
    end
    local power_network = {}
    for _, pole in ipairs(powerpole) do
        power_network[#power_network + 1] = new_network(pole)
    end
    if #power_network > 1 then
        local remove_net = {}
        for idx = 1, #power_network -1 do
            local net1 = power_network[idx]
            for i = idx + 1, #power_network do
                local connect = shortest_conect(power_network[idx].poles, power_network[i].poles)
                if connect then
                    remove_net[idx] = true
                    local net2 = power_network[i]
                    for _, l in ipairs(net1.lines) do
                        net2.lines[#net2.lines + 1] = l
                    end
                    net2.lines[#net2.lines + 1] = create_line(connect[1], connect[2])
                    for _, p in ipairs(net1.poles) do
                        set_supply_area(net2.area, p)
                        table.insert(net2.poles, p)
                    end
                    goto continue
                end
            end
            ::continue::
        end
        local network = {}
        for index, value in ipairs(power_network) do
            if not remove_net[index] then
                network[#network + 1] = value
            end
        end
        power_network = network
    end
    global.power_network = power_network
    for _, e in ipairs(capacitance) do
        set_network_id(gw, power_network, e)
    end
end

function M.remove_pole()
end

return M