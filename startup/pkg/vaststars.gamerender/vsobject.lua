local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iprototype = require "gameplay.interface.prototype"
local imodifier = ecs.import.interface "ant.modifier|imodifier"
local icanvas = ecs.require "engine.canvas"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local CONSTRUCT_COLOR_INVALID <const> = math3d.constant "null"

local function set_position(self, position)
    assert(position)
    self.game_object:send("obj_motion", "set_position", position)
end

local function set_dir(self, dir)
    self.game_object:send("obj_motion", "set_rotation", ROTATORS[dir])
end

local function remove(self)
    if self.game_object then
        self.game_object:remove()
    end

    for _, type in ipairs({icanvas.types().BUILDING_BASE}) do
        self:del_canvas(type)
    end
end

local function update(self, t)
    local typeobject = iprototype.queryByName(t.prototype_name or self.prototype_name)
    self.game_object:update(typeobject.model, "opaque", CONSTRUCT_COLOR_INVALID, t.animation_name)

    self.type = t.type or self.type
    self.prototype_name = t.prototype_name or self.prototype_name
end

-- TODO: remove this function, simply use update
local function emissive_color_update(self, color)
    self.emissive_color = color
    local typeobject = iprototype.queryByName(self.prototype_name)
    self.game_object:update(typeobject.model, "opaque", CONSTRUCT_COLOR_INVALID, nil, nil, color)
end

local function animation_name_update(self, animation_name, final_frame)
    local typeobject = iprototype.queryByName(self.prototype_name)
    self.game_object:update(typeobject.model, "opaque", CONSTRUCT_COLOR_INVALID, animation_name, final_frame, self.emissive_color)
end

local function has_animation(self, animation_name)
    return self.game_object:has_animation(animation_name)
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

local function add_canvas(self, type, ...)
    self:del_canvas(type)
    self.canvas_cache[type] = {...}
    self.canvas_id[type] = self.id

    local items = self.canvas_cache[type][1](table.unpack(self.canvas_cache[type], 2))
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
    self.canvas_cache[type] = self.id
end

local function mod_canvas(self, x, y, srt)
    do
        local itype = icanvas.types().BUILDING_BASE
        icanvas.remove_item(itype, self.canvas_id[itype])
        if self.canvas_cache[itype] then
            local f = self.canvas_cache[itype][1]
            self.canvas_cache[itype][2] = srt
            local items = f(table.unpack(self.canvas_cache[itype], 2))
            for _, t in ipairs(items) do
                icanvas.add_item(itype, self.id, table.unpack(t))
            end
        end
    end
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
    local typeobject = iprototype.queryByName(init.prototype_name)
    local game_object = assert(igame_object.create({
        prefab = typeobject.model,
        group_id = init.group_id,
        state = "opaque",
        color = CONSTRUCT_COLOR_INVALID,
        srt = {r = ROTATORS[init.dir], t = init.position},
        parent = nil,
        slot = nil,
    }))

    local vsobject = {
        id = init.id,
        prototype_name = init.prototype_name,
        type = init.type,
        group_id = init.group_id,
        slots = {}, -- slot_name -> model
        canvas_id = {}, -- type -> canvas_id
        canvas_cache = {}, -- type -> {func, ...}

        game_object = game_object,
        srt_modifier = imodifier.create_bone_modifier(game_object.hitch_entity_object.id, init.group_id, "/pkg/vaststars.resources/glb/animation/Interact_build.glb|animation.prefab", "Bone"), -- TODO

        --
        update = update,
        get_position = get_position,
        set_position = set_position,
        set_dir = set_dir,
        remove = remove,
        attach = attach,
        detach = detach,
        emissive_color_update = emissive_color_update,
        animation_name_update = animation_name_update,
        modifier = modifier,
        add_canvas = add_canvas,
        del_canvas = del_canvas,
        mod_canvas = mod_canvas,
        has_animation = has_animation,
    }
    return vsobject
end
