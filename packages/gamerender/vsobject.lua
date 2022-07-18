local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc = mathpkg.constant
local game_object = ecs.require "engine.game_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity = ecs.import.interface "ant.render|ientity"
local imaterial	= ecs.import.interface "ant.asset|imaterial"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local imesh = ecs.import.interface "ant.asset|imesh"
local ifs = ecs.import.interface "ant.scene|ifilter_state"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iprototype = require "gameplay.interface.prototype"
local imodifier = ecs.import.interface "ant.modifier|imodifier"
local terrain = ecs.require "terrain"

local plane_vb <const> = {
	-0.5, 0, 0.5, 0, 1, 0,	--left top
	0.5,  0, 0.5, 0, 1, 0,	--right top
	-0.5, 0,-0.5, 0, 1, 0,	--left bottom
	-0.5, 0,-0.5, 0, 1, 0,
	0.5,  0, 0.5, 0, 1, 0,
	0.5,  0,-0.5, 0, 1, 0,	--right bottom
}

local rotators <const> = {
    N = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(0)}),
    E = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    S = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    W = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local CONSTRUCT_COLOR_INVALID <const> = math3d.constant "null"
local CONSTRUCT_COLOR_RED <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 0.55})
local CONSTRUCT_COLOR_GREEN <const> = math3d.constant("v4", {0.0, 2.5, 0.0, 0.55})
local CONSTRUCT_COLOR_WHITE <const> = math3d.constant("v4", {1.5, 2.5, 1.5, 0.55})
local CONSTRUCT_COLOR_YELLOW <const> = math3d.constant("v4", {2.5, 2.5, 0.0, 0.55})

local CONSTRUCT_BLOCK_COLOR_INVALID <const> = math3d.constant "null"
local CONSTRUCT_BLOCK_COLOR_RED <const> = math3d.constant("v4", {1, 0.0, 0.0, 1.0})
local CONSTRUCT_BLOCK_COLOR_GREEN <const> = math3d.constant("v4", {0.0, 1, 0.0, 1.0})
local CONSTRUCT_BLOCK_COLOR_WHITE <const> = math3d.constant("v4", {1, 1, 1, 1.0})

local FLUIDFLOW_BLUE <const> = math3d.constant("v4", {0.0, 0.0, 2.5, 0.55})
local FLUIDFLOW_CHARTREUSE <const> = math3d.constant("v4", {1.2, 2.5, 0.0, 0.55})
local FLUIDFLOW_CHOCOLATE <const> = math3d.constant("v4", {2.1, 2.0, 0.3, 0.55})
local FLUIDFLOW_DARKVIOLET <const> = math3d.constant("v4", {1.4, 0.0, 2.1, 0.55})

local typeinfos = {
    ["indicator"] = {state = "translucent", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已确认
    ["construct"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_GREEN, block_edge_size = 4}, -- 未确认, 合法
    ["invalid_construct"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_RED, block_edge_size = 4}, -- 未确认, 非法
    ["confirm"] = {state = "translucent", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已确认
    ["constructed"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已施工
    ["teardown"] = {state = "translucent", color = CONSTRUCT_COLOR_YELLOW, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 拆除

    ["fluidflow_blue"] = {state = "translucent", color = FLUIDFLOW_BLUE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
    ["fluidflow_chartreuse"] = {state = "translucent", color = FLUIDFLOW_CHARTREUSE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
    ["fluidflow_chocolate"] = {state = "translucent", color = FLUIDFLOW_CHOCOLATE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
    ["fluidflow_darkviolet"] = {state = "translucent", color = FLUIDFLOW_DARKVIOLET, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0},
}

local gen_id do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

local entity_events = {}
entity_events.set_material_property = function(_, e, ...)
    imaterial.set_property(world:entity(e.id), ...)
end
entity_events.set_position = function(_, e, ...)
    iom.set_position(e, ...)
end
entity_events.set_rotation = function(_, e, ...)
    iom.set_rotation(e, ...)
end
entity_events.update_render_object = function(_, e, ...)
    irq.update_render_object(e, true)
end

local function create_block(color, block_edge_size, area, position, rotation)
    if color == CONSTRUCT_BLOCK_COLOR_INVALID then
        return
    end
    local width, height = iprototype.unpackarea(area)
    local eid = ecs.create_entity{
		policy = {
			"ant.render|simplerender",
			"ant.general|name",
		},
		data = {
			scene 		= { r = rotation, s = {terrain.tile_size * width + block_edge_size, 1, terrain.tile_size * height + block_edge_size}, t = position},
			material 	= "/pkg/vaststars.resources/materials/singlecolor.material",
			filter_state= "main_view",
			name 		= ("plane_%d"):format(gen_id()),
			simplemesh 	= imesh.init_mesh(ientity.create_mesh({"p3|n3", plane_vb}, nil, math3d.ref(math3d.aabb({-0.5, 0, -0.5}, {0.5, 0, 0.5}))), true),
			on_ready = function (e)
				w:sync("render_object:in", e)
				ifs.set_state(e, "main_view", true)
				imaterial.set_property(e, "u_color", color)
				w:sync("render_object_update:out", e)
			end
		},
	}

    return ientity_object.create(eid, entity_events)
end

local function get_rotation(self)
    return math3d.ref(iom.get_rotation(world:entity(self.game_object.hitch_entity_object.id)))
end

local function set_position(self, position)
    local e = world:entity(self.game_object.hitch_entity_object.id) -- TODO: hitch object may not created yet
    if not e then
        return
    end

    assert(world:entity(self.game_object.hitch_entity_object.id))
    iom.set_position(world:entity(self.game_object.hitch_entity_object.id), position)
    if self.block_object then
        local block_pos = math3d.ref(math3d.add(position, {0, terrain.surface_height, 0}))
        self.block_object:send("set_position", block_pos)
    end
end

local function get_position(self)
    return iom.get_position(world:entity(self.game_object.hitch_entity_object.id))
end

local function set_dir(self, dir)
    local e = world:entity(self.game_object.hitch_entity_object.id) -- TODO: hitch object may not created yet
    if not e then
        return
    end
    iom.set_rotation(world:entity(self.game_object.hitch_entity_object.id), rotators[dir])
    if self.block_object then
        self.block_object:send("set_rotation", rotators[dir])
    end
end

local function remove(self)
    if self.game_object then
        self.game_object:remove()
    end

    if self.block_object then
        self.block_object:remove()
    end
end

local function update(self, t)
    local typeinfo = typeinfos[t.type or self.type]
    local typeobject = iprototype.queryByName("entity", t.prototype_name or self.prototype_name)
    self.game_object:update(typeobject.model, typeinfo.state, typeinfo.color)

    if self.block_object then
        self.block_object:remove()
        self.block_object = nil
    end

    if typeinfo.block_color ~= CONSTRUCT_BLOCK_COLOR_INVALID then
        local e = world:entity(self.game_object.hitch_entity_object.id) -- TODO: hitch object may not created yet
        if e then
            local typeobject = iprototype.queryByName("entity", self.prototype_name)
            local block_pos = math3d.ref(math3d.add(self:get_position(), math3d.vector(0, terrain.surface_height, 0)))
            local rotation = get_rotation(self)
            self.block_object = create_block(typeinfo.block_color, typeinfo.block_edge_size, typeobject.area, block_pos, rotation)
        end
    end

    self.type = t.type or self.type
    self.prototype_name = t.prototype_name or self.prototype_name
end

local function attach(self, ...)
    self.game_object:attach(...)
end

local function detach(self, ...)
    self.game_object:detach(...)
end

local function animation_update(self, animation_name, process)
    local typeinfo = typeinfos[self.type]
    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self.game_object:update(typeobject.model, typeinfo.state, typeinfo.color, animation_name, process)
end

local function modifier(self, opt, ...)
    -- self.game_object:send("modifier", opt, self.srt_modifier, ...) -- TODO
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

    local game_object = assert(game_object.create(typeobject.model, init.group_id, typeinfo.state, typeinfo.color, {r = rotators[init.dir], t = init.position}))
    local block_pos = math3d.ref(math3d.add(init.position, {0, terrain.surface_height, 0}))
    local block_object = create_block(typeinfo.block_color, typeinfo.block_edge_size, typeobject.area, block_pos, rotators[init.dir])

    local vsobject = {
        id = init.id,
        prototype_name = init.prototype_name,
        type = init.type,
        group_id = init.group_id,

        game_object = game_object,
        block_object = block_object,
        srt_modifier = imodifier.create_bone_modifier(game_object.hitch_entity_object.id, init.group_id, "/pkg/vaststars.resources/glb/animation/Interact_build.glb|animation.prefab", "Bone"), -- TODO

        --
        update = update,
        set_position = set_position,
        get_position = get_position,
        set_dir = set_dir,
        remove = remove,
        attach = attach,
        detach = detach,
        animation_update = animation_update,
        modifier = modifier,
    }
    return vsobject
end
