local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iprototype = require "gameplay.interface.prototype"
local imodifier = ecs.import.interface "ant.modifier|imodifier"
local terrain = ecs.require "terrain"
local icanvas = ecs.require "engine.canvas"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local iplant = ecs.require "engine.plane"

local BLOCK_POSITION_OFFSET <const> = math3d.constant("v4", {0, 3.78, 0, 0.0})
local CONSTRUCT_COLOR_INVALID <const> = math3d.constant "null"
local CONSTRUCT_COLOR_RED <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 0.55})
local CONSTRUCT_COLOR_GREEN <const> = math3d.constant("v4", {0.0, 2.5, 0.0, 0.55})
local CONSTRUCT_COLOR_WHITE <const> = math3d.constant("v4", {1.5, 2.5, 1.5, 0.55})
local CONSTRUCT_COLOR_YELLOW <const> = math3d.constant("v4", {2.5, 2.5, 0.0, 0.55})

local CONSTRUCT_BLOCK_COLOR_INVALID <const> = math3d.constant "null"
local CONSTRUCT_BLOCK_COLOR_RED <const> = math3d.constant("v4", {2.5, 0.2, 0.2, 0.4})
local CONSTRUCT_BLOCK_COLOR_GREEN <const> = math3d.constant("v4", {0.0, 1, 0.0, 1.0})
local CONSTRUCT_BLOCK_COLOR_WHITE <const> = math3d.constant("v4", {1, 1, 1, 1.0})

local FLUIDFLOW_BLUE <const> = math3d.constant("v4", {0.0, 0.0, 2.5, 0.55})
local FLUIDFLOW_CHARTREUSE <const> = math3d.constant("v4", {1.2, 2.5, 0.0, 0.55})
local FLUIDFLOW_CHOCOLATE <const> = math3d.constant("v4", {2.1, 2.0, 0.3, 0.55})
local FLUIDFLOW_DARKVIOLET <const> = math3d.constant("v4", {1.4, 0.0, 2.1, 0.55})

local CONSTRUCT_POWER_POLE_BLOCK_COLOR_GREEN <const> = math3d.constant("v4", {0.13, 1.75, 2.4, 0.5})
local CONSTRUCT_POWER_POLE_BLOCK_COLOR_RED <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 1.0})

local typeinfos = {
    ["indicator"] = {state = "translucent", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已确认
    ["construct"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_GREEN, block_edge_size = 0}, -- 未确认, 合法
    ["invalid_construct"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_RED, block_edge_size = 0}, -- 未确认, 非法
    ["confirm"] = {state = "translucent", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已确认
    ["constructed"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已施工
    ["task"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_RED, block_edge_size = 4}, -- 新手任务初始需要拆除建筑的底色
    ["selected"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_GREEN, block_edge_size = 6},

    ["fluidflow_blue"] = {state = "translucent", color = FLUIDFLOW_BLUE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
    ["fluidflow_chartreuse"] = {state = "translucent", color = FLUIDFLOW_CHARTREUSE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
    ["fluidflow_chocolate"] = {state = "translucent", color = FLUIDFLOW_CHOCOLATE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
    ["fluidflow_darkviolet"] = {state = "translucent", color = FLUIDFLOW_DARKVIOLET, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
}

for _, typeobject in pairs(iprototype.each_maintype "entity") do
    if typeobject.supply_area then
        local w, h = typeobject.supply_area:match("(%d+)x(%d+)")
        w, h = tonumber(w), tonumber(h)

        local ew, eh = iprototype.unpackarea(typeobject.area)
        assert(w == h)
        assert(ew == eh)
        typeinfos[("power_pole_construct_%s"):format(typeobject.supply_area)] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_POWER_POLE_BLOCK_COLOR_GREEN, block_edge_size = (w - ew) * 10}
        typeinfos[("power_pole_invalid_construct_%s"):format(typeobject.supply_area)] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_POWER_POLE_BLOCK_COLOR_RED, block_edge_size = (w - ew) * 10}
        typeinfos[("power_pole_selected_%s"):format(typeobject.supply_area)] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_POWER_POLE_BLOCK_COLOR_GREEN, block_edge_size = (w - ew) * 10}
        typeinfos[("power_pole_confirm_%s"):format(typeobject.supply_area)] = {state = "opaque", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_POWER_POLE_BLOCK_COLOR_GREEN, block_edge_size = (w - ew) * 10}
    end
end

local function set_position(self, position)
    assert(position)
    self.game_object:send("obj_motion", "set_position", position)
    if self.block then
        local block_pos = math3d.ref(math3d.add(position, BLOCK_POSITION_OFFSET))
        self.block:send("obj_motion", "set_position", block_pos)
    end
end

local function set_dir(self, dir)
    self.game_object:send("obj_motion", "set_rotation", ROTATORS[dir])
    if self.block then
        self.block:send("obj_motion", "set_rotation", ROTATORS[dir])
    end
end

local function remove(self)
    if self.game_object then
        self.game_object:remove()
    end

    if self.block then
        self.block:remove()
    end

    for _, type in ipairs({icanvas.types().ICON, icanvas.types().BUILDING_BASE}) do
        self:del_canvas(type)
    end
end

local function update(self, t)
    local typeinfo = typeinfos[t.type or self.type]
    local typeobject = iprototype.queryByName("entity", t.prototype_name or self.prototype_name)
    self.game_object:update(typeobject.model, typeinfo.state, typeinfo.color)
    assert(t.srt)

    if self.block then
        self.block:remove()
        self.block = nil
    end

    if typeinfo.block_color ~= CONSTRUCT_BLOCK_COLOR_INVALID then
        local typeobject = iprototype.queryByName("entity", self.prototype_name)
        local w, h = iprototype.unpackarea(typeobject.area)
        w, h = w + 1, h + 1
        local block_pos = math3d.ref(math3d.add(t.srt.t, BLOCK_POSITION_OFFSET))
        local srt = {r = t.srt.r, s = {terrain.tile_size * w + typeinfo.block_edge_size, 1, terrain.tile_size * h + typeinfo.block_edge_size}, t = block_pos}
        self.block = iplant.create("/pkg/vaststars.resources/materials/singlecolor.material", "u_color", typeinfo.block_color, srt)
    end

    self.type = t.type or self.type
    self.prototype_name = t.prototype_name or self.prototype_name
end

-- TODO: remove this function, simply use update
local function animation_update(self, animation_name, process)
    local typeinfo = typeinfos[self.type]
    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self.game_object:update(typeobject.model, typeinfo.state, typeinfo.color, animation_name, process)
end

-- TODO: remove this function, simply use update
local function emissive_color_update(self, color)
    local typeinfo = typeinfos[self.type]
    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self.game_object:update(typeobject.model, typeinfo.state, typeinfo.color, nil, nil, color)
end

local function attach(self, slot_name, model, ...)
    if self.slots[slot_name] == model then
        return
    end
    self.game_object:detach()
    self.game_object:attach(slot_name, model, ...)
	self.slots[slot_name] = model
end

local function detach(self, ...)
    self.game_object:detach(...)
    self.slots = {}
end

local function modifier(self, opt, ...)
    imodifier[opt](self.srt_modifier, ...)
end

local function add_canvas(self, type, items)
    self:del_canvas(type)
    self.canvas_id[type] = self.id
    for _, t in ipairs(items) do
        icanvas.add_item(type, self.id, table.unpack(t))
    end
end

local function del_canvas(self, type)
    if not self.canvas_id or not self.canvas_id[type] then
        return
    end
    icanvas.remove_item(type, self.canvas_id[type])
    self.canvas_id[type] = nil
end

local function get_position(self)
    local e <close> = w:entity(self.game_object.hitch_entity_object.id)
    return iom.get_position(e)
end

-- init = {
--     prototype_name = prototype_name,
--     type = xxx,
--     position = position,
--     dir = 'N',
-- }
return function (init)
    local typeobject = iprototype.queryByName("entity", init.prototype_name)
    local typeinfo = assert(typeinfos[init.type], ("invalid type `%s`"):format(init.type))

    local game_object = assert(igame_object.create({
        prefab = typeobject.model,
        group_id = init.group_id,
        state = typeinfo.state,
        color = typeinfo.color,
        srt = {r = ROTATORS[init.dir], t = init.position},
        parent = nil,
        slot = nil,
    }))

    local w, h = iprototype.unpackarea(typeobject.area)
    w, h = w + 1, h + 1

    local block_pos = math3d.ref(math3d.add(init.position, BLOCK_POSITION_OFFSET))
    local srt = {r = ROTATORS[init.dir], s = {terrain.tile_size * w + typeinfo.block_edge_size, 1, terrain.tile_size * h + typeinfo.block_edge_size}, t = block_pos}
    local block
    if typeinfo.block_color ~= CONSTRUCT_COLOR_INVALID then
        block = iplant.create("/pkg/vaststars.resources/materials/singlecolor.material", "u_color", typeinfo.block_color, srt)
    end

    local vsobject = {
        id = init.id,
        prototype_name = init.prototype_name,
        type = init.type,
        group_id = init.group_id,
        slots = {}, -- slot_name -> model
        canvas_id = {}, -- type -> canvas_id

        game_object = game_object,
        block = block,
        srt_modifier = imodifier.create_bone_modifier(game_object.hitch_entity_object.id, init.group_id, "/pkg/vaststars.resources/glb/animation/Interact_build.glb|animation.prefab", "Bone"), -- TODO

        --
        update = update,
        get_position = get_position,
        set_position = set_position,
        set_dir = set_dir,
        remove = remove,
        attach = attach,
        detach = detach,
        animation_update = animation_update,
        emissive_color_update = emissive_color_update,
        modifier = modifier,
        add_canvas = add_canvas,
        del_canvas = del_canvas,
    }
    return vsobject
end
