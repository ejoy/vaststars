local ecs = ...
local world = ecs.world
local w = world.w

local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS

local igame_object = ecs.require "engine.game_object"
local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"

local function set_position(self, position)
    self.game_object:send("obj_motion", "set_position", math3d.live(position))
end

local function set_dir(self, dir)
    self.game_object:send("obj_motion", "set_rotation", math3d.live(ROTATORS[dir]))
end

local function remove(self)
    if self.game_object then
        self.game_object:remove()
    end
end

local function update(self, t)
    self.prototype_name = t.prototype_name or self.prototype_name
    local typeobject = iprototype.queryByName(self.prototype_name)
    local model
    if t.state == "translucent" then
        model = igame_object.replace_prefab(typeobject.model, "translucent.prefab")
    else
        if typeobject.work_status and typeobject.work_status[t.work_status] then
            model = igame_object.replace_prefab(typeobject.model, ("%s.prefab"):format(t.work_status))
        else
            model = typeobject.model
        end
    end

    self.game_object:update {
        prefab = model,
        color = t.color,
        emissive_color = t.emissive_color,
        render_layer = t.render_layer,
    }
end

local function modifier(self, ...)
    self.game_object:modifier(...)
end

-- init = {
--     prototype_name = prototype_name,
--     type = xxx,
--     position = position,
--     dir = 'N',
-- }
return function (init)
    local typeobject = iprototype.queryByName(init.prototype_name)

    local model = typeobject.model
    if init.debris then
        local typeobject = iprototype.queryById(init.debris)
        model = igame_object.replace_prefab(typeobject.model, "debris.prefab")
    end
    if init.state == "translucent" then
        model = igame_object.replace_prefab(typeobject.model, "translucent.prefab")
    end

    local game_object = assert(igame_object.create({
        prefab = model,
        group_id = init.group_id,
        color = init.color,
        srt = {r = ROTATORS[init.dir], t = init.position},
        parent = nil,
        slot = nil,
        state = init.state,
        emissive_color = init.emissive_color,
        render_layer = init.render_layer,
    }))

    local vsobject = {
        id = init.id,
        prototype_name = init.prototype_name,
        type = init.type,
        group_id = init.group_id,
        slots = {}, -- slot_name -> model
        game_object = game_object,

        --
        update = update,
        set_position = set_position,
        set_dir = set_dir,
        remove = remove,
        modifier = modifier,
    }
    return vsobject
end
