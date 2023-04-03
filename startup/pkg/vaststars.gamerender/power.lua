local gameplay_core     = require "gameplay.core"
local iprototype        = require "gameplay.interface.prototype"
local global            = require "global"

local M = {}
local function set_power_supply_area(area, e)
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
    set_power_supply_area(area, e)
    net.area = area
    return net
end

-- area
local function min_area_x(e) return e.x end
local function max_area_x(e) return e.x + e.w - 1 end
local function min_area_y(e) return e.y end
local function max_area_y(e) return e.y + e.h - 1 end

-- power_supply_distance
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

local function can_connect(e0, e1)
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
    local pos1 = {pole1.x, pole1.y}
    local pos2 = {pole2.x, pole2.y}
    local dx = (pos1[1] - pos2[1])
    local dz = (pos1[2] - pos2[2])
    return dx * dx + dz * dz
end

local function shortest_conect(poles1, poles2)
    local connects = {}
    for _, p1 in ipairs(poles1) do
        connects[p1] = {}
        for _, p2 in ipairs(poles2) do
            if can_connect(p1, p2) then
                local cons = connects[p1]
                cons[#cons + 1] = {p1, p2, dist = dist_sqr(p1, p2)}
            end
        end
    end
    for _, value in pairs(connects) do
        if #value > 1 then
            table.sort(value, function (a, b)
                return a.dist < b.dist
            end)
        end
    end
    
    return connects
end

local function area_supply_overlap(e0, e1)
    if max_area_x(e0) < min_supply_x(e1) or min_area_x(e0) > max_supply_x(e1) or max_area_y(e0) < min_supply_y(e1) or min_area_y(e0) > max_supply_y(e1) then
        return false
    end
    return true
end


local function remove_from_table(pole, poles)
    for index, value in ipairs(poles) do
        if pole == value then
            table.remove(poles, index)
            break
        end
    end
end
function M:clear_temp_pole(pole, keep)
    local network = global.power_network
    if not self.temp_pole[pole.key] or not network then
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
    local lines = self.temp_pole[pole.key].lines
    if lines and #lines > 0 then
       for _, line in ipairs(lines) do
            remove_from_table(line.p1, line.p2.targets)
            remove_from_table(line.p2, line.p1.targets)
            if line.p2.power_network_link and line.p1.power_network_link then
                line.p2.power_network_link_target = line.p2.power_network_link_target - 1
                line.p1.power_network_link_target = line.p1.power_network_link_target - 1
            end
       end
    end
    if not keep then
        self.temp_pole[pole.key] = nil
    end

    if index then
        table.remove(poles, index)
        if #poles < 1 then
            table.remove(network, net_index)
        end
    end
end

local function do_create_line(pole1, pole2)
    pole1.targets[#pole1.targets + 1] = pole2
    pole2.targets[#pole2.targets + 1] = pole1
    if pole1.power_network_link and pole2.power_network_link then
        pole1.power_network_link_target = pole1.power_network_link_target + 1
        pole2.power_network_link_target = pole2.power_network_link_target + 1
    end
    return { p1 = pole1, p2 = pole2 }
end

local function create_lines(head, connects)
    local function has_connected(p, poles)
        for _, connected in ipairs(poles) do
            for _, target in ipairs(connected.targets) do
                if p == target then
                    return p.power_network_link and connected.power_network_link
                end
            end
        end
        return false
    end
    local lines = {}
    local connected_pole = {}
    for _, con in ipairs(connects) do
        -- same head, multi tail
        assert(con[1] == head )
        local tail = con[2]
        local skip = has_connected(tail, connected_pole)
        if not skip and head.power_network_link_target < 5 and tail.power_network_link_target < 5 then
            lines[#lines + 1] = do_create_line(head, tail)
            connected_pole[#connected_pole + 1] = tail
        end
    end
    return lines
end

function M:merge_pole(pole, add)
    local network = global.power_network
    if pole.key and self.temp_pole[pole.key] then
        self:clear_temp_pole(pole)
    end
    local has_net
    local all_connects = {}
    for _, nw in ipairs(network) do
        local connects = shortest_conect({pole}, nw.poles)
        if not has_net and #connects[pole] > 0 then
            nw.poles[#nw.poles + 1] = pole
            has_net = true
        end
        all_connects[#all_connects + 1] = connects
    end
    if has_net then
        local lines = {}
        for _, connects in ipairs(all_connects) do
            local ls = create_lines(pole, connects[pole])
            for _, l in ipairs(ls) do
                lines[#lines + 1] = l
            end
        end
        if not pole.key then
            for _, line in ipairs(lines) do
                self.pole_lines[self.pole_lines + 1] = line
            end
        else
            self.temp_pole[pole.key] = {lines = lines, pole = pole}
        end
    else
        if add then
            network[#network + 1] = new_network(pole)
        end
        if pole.key then
            self.temp_pole[pole.key] = {pole = pole}
        end
    end
end

function M:get_network_id(e, first)
    local net = {}
    local network = global.power_network
    for idx, pn in ipairs(network) do
        local minx = min_area_x(e)
        local maxx = max_area_x(e)
        local miny = min_area_y(e)
        local maxy = max_area_y(e)
        if pn.area[miny][minx] or pn.area[miny][maxx] or pn.area[maxy][minx] or pn.area[maxy][maxx] then
            net[#net + 1] = idx
            if first then
                break
            end
        end
    end
    return net
end

local function merge_network(net1, net2)
    for _, p in ipairs(net1.poles) do
        set_power_supply_area(net2.area, p)
        table.insert(net2.poles, p)
    end
end

function M:set_network_id(gw, capacitance)
    for _, e in ipairs(capacitance) do
        local nid = self:get_network_id(e)
        if #nid > 1 then
            -- merge network
            local network = global.power_network
            local remove_flags = {}
            for i = 1, #nid - 1 do
                remove_flags[nid[i]] = true
                merge_network(network[nid[i]], network[nid[i+1]])
            end
            local new_network = {}
            for index, value in ipairs(network) do
                if not remove_flags[index] then
                    new_network[#new_network + 1] = value
                end
            end
            global.power_network = new_network
        end
    end
    for _, e in ipairs(capacitance) do
        local nid = self:get_network_id(e, true)
        local v = gw.entity[e.eid]
        if v.capacitance then
            v.capacitance.network = #nid > 0 and nid[1] or 0
        end
    end
end

function M:clear_all_temp_pole()
    if self.temp_pole then
        for _, pole in pairs(self.temp_pole) do
            self:clear_temp_pole(pole.pole, true)
        end
    end
    self.temp_pole = {}
end

function M:build_power_network(gw)
    self:clear_all_temp_pole()
    local powerpole = {}
    local capacitance = {}
    for v in gameplay_core.select("eid:in building:in capacitance?in") do
        local e = v.building
        local typeobject = iprototype.queryById(e.prototype)
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh
        if typeobject.power_supply_area then
            sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        end
        if v.capacitance then
            capacitance[#capacitance + 1] = {
                targets = {},
                power_network_link_target = 0,
                -- name = typeobject.name,
                eid = v.eid,
                x = e.x,
                y = e.y,
                w = aw,
                h = ah,
            }
        end
        if typeobject.power_network_link or typeobject.power_supply_distance then
            powerpole[#powerpole + 1] = {
                targets = {},
                power_network_link_target = 0,
                -- name = typeobject.name,
                eid = v.eid,
                x = e.x,
                y = e.y,
                w = aw,
                h = ah,
                sw = tonumber(sw),
                sh = tonumber(sh),
                sd = typeobject.power_supply_distance,
                power_network_link = typeobject.power_network_link
            }
        end
    end

    self.pole_lines = {}

    local power_network = {}
    for _, pole in ipairs(powerpole) do
        power_network[#power_network + 1] = new_network(pole)
    end
    if #power_network > 1 then
        local remove_flags = {}
        for idx = 1, #power_network -1 do
            local net1 = power_network[idx]
            for i = idx + 1, #power_network do
                local net2 = power_network[i]
                local has_connect = false
                local connects = shortest_conect(net2.poles, net1.poles)
                for key, value in pairs(connects) do
                    local lines = create_lines(key, value)
                    for _, line in ipairs(lines) do
                        self.pole_lines[#self.pole_lines + 1] = line
                    end
                    if not has_connect and #lines > 0 then
                        remove_flags[idx] = true
                        has_connect = true
                    end
                end
                if has_connect then
                    merge_network(net1, net2)
                    goto continue
                end
            end
            ::continue::
        end
        local network = {}
        for index, value in ipairs(power_network) do
            if not remove_flags[index] then
                network[#network + 1] = value
            end
        end
        power_network = network
    end
    global.power_network = power_network
    self:set_network_id(gw, capacitance)
end

function M:get_pole_lines()
    return self.pole_lines
end

function M:get_temp_pole()
    return self.temp_pole
end

function M:remove_pole()
end

return M