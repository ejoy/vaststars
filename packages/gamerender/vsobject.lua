local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local mathpkg = import_package"ant.math"
local mc, mu = mathpkg.constant, mathpkg.util
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity = ecs.import.interface "ant.render|ientity"
local imaterial	= ecs.import.interface "ant.asset|imaterial"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local imesh = ecs.import.interface "ant.asset|imesh"
local ifs = ecs.import.interface "ant.scene|ifilter_state"
local irq = ecs.import.interface "ant.render|irenderqueue"
local assetmgr = import_package "ant.asset"
local get_canvas_rect = require "utility.get_canvas_rect"
local tile_size <const> = 10.0
local iprototype = require "gameplay.interface.prototype"

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

local CONSTRUCT_COLOR_INVALID <const> = {}
local CONSTRUCT_COLOR_RED <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 0.55})
local CONSTRUCT_COLOR_GREEN <const> = math3d.constant("v4", {0.0, 2.5, 0.0, 0.55})
local CONSTRUCT_COLOR_WHITE <const> = math3d.constant("v4", {1.5, 2.5, 1.5, 0.55})
local CONSTRUCT_COLOR_YELLOW <const> = math3d.constant("v4", {2.5, 2.5, 0.0, 0.55})

local CONSTRUCT_BLOCK_COLOR_INVALID <const> = {}
local CONSTRUCT_BLOCK_COLOR_RED <const> = math3d.constant("v4", {1, 0.0, 0.0, 1.0})
local CONSTRUCT_BLOCK_COLOR_GREEN <const> = math3d.constant("v4", {0.0, 1, 0.0, 1.0})
local CONSTRUCT_BLOCK_COLOR_WHITE <const> = math3d.constant("v4", {1, 1, 1, 1.0})

local FLUID_ICON_COLOR <const> = math3d.constant("v4", {1, 1, 1, 1.0})

local typeinfos = {
    ["indicator"] = {state = "translucent", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已确认
    ["construct"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_GREEN, block_edge_size = 4}, -- 未确认, 合法
    ["invalid_construct"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_RED, block_edge_size = 4}, -- 未确认, 非法
    ["confirm"] = {state = "translucent", color = CONSTRUCT_COLOR_WHITE, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已确认
    ["constructed"] = {state = "opaque", color = CONSTRUCT_COLOR_INVALID, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 已施工
    ["teardown"] = {state = "translucent", color = CONSTRUCT_COLOR_YELLOW, block_color = CONSTRUCT_BLOCK_COLOR_INVALID, block_edge_size = 0}, -- 拆除
}

local gen_id do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

local entity_events = {}
entity_events.set_material_property = function(e, ...)
    imaterial.set_property(world:entity(e.id), ...)
end
entity_events.set_position = function(e, ...)
    iom.set_position(e, ...)
end
entity_events.set_rotation = function(e, ...)
    iom.set_rotation(e, ...)
end
entity_events.update_render_object = function(e, ...)
    irq.update_render_object(e, true)
end

local function create_block(color, block_edge_size, area, position, rotation)
    if color == CONSTRUCT_BLOCK_COLOR_INVALID then
        return
    end
    local width, height = iprototype:unpackarea(area)
    local eid = ecs.create_entity{
		policy = {
			"ant.render|simplerender",
			"ant.general|name",
		},
		data = {
			scene 		= { srt = {r = rotation, s = {tile_size * width + block_edge_size, 1.0, tile_size * height + block_edge_size}, t = position}},
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

local function create_texture_plane_entity(tex, tex_rect, tex_size, position)
    local eid = ecs.create_entity{
        policy = {
            "ant.render|simplerender",
            "ant.general|name",
        },
        data = {
            name = ("texture_plane"):format(gen_id()),
            simplemesh = imesh.init_mesh(ientity.plane_mesh(mu.texture_uv(tex_rect, tex_size)), true),
            material = "/pkg/vaststars.resources/materials/translucent_texture_plane.material",
            filter_state= "main_view",
            scene = {
                srt = {
                    s = {10, 1, 10},
                    t = {position[1], 1.0, position[3]},
                }
            },
            on_ready = function (e)
                w:sync("render_object:in", e)
                imaterial.set_property(e, "u_basecolor_factor", FLUID_ICON_COLOR)
                local texobj = assetmgr.resource(tex)
                imaterial.set_property(e, "s_basecolor", {texture=texobj, stage=0})
            end
        }
    }

    return ientity_object.create(eid, entity_events)
end

local function set_srt(e, srt)
    if not srt then
        return
    end
    iom.set_scale(e, srt.s)
    iom.set_rotation(e, srt.r)
    iom.set_position(e, srt.t)
end

local function get_rotation(self)
    return math3d.ref(iom.get_rotation(world:entity(self.game_object.root)))
end

local function set_position(self, position)
    iom.set_position(world:entity(self.game_object.root), position)
    if self.block_entity_object then
        local block_pos = math3d.ref(math3d.add(math3d.vector(position), {0, 1.0, 0}))
        self.block_entity_object:send("set_position", block_pos)
    end
    if self.fluid_icon_entity_object then
        self.fluid_icon_entity_object:send("set_position", position)
    end
end

local function get_position(self)
    return iom.get_position(world:entity(self.game_object.root))
end

local function set_dir(self, dir)
    iom.set_rotation(world:entity(self.game_object.root), rotators[dir])
    if self.block_entity_object then
        self.block_entity_object:send("set_rotation", rotators[dir])
    end
end

local function remove(self)
    local game_object = self.game_object
    if game_object then
        game_object:remove()
    end

    if self.block_entity_object then
        self.block_entity_object:remove()
    end

    if self.fluid_icon_entity_object then
        self.fluid_icon_entity_object:remove()
    end
end

--TODO bad taste
local function update(self, t)
    local old_typeinfo = typeinfos[self.type]
    local new_typeinfo = typeinfos[t.type or self.type]

    if t.prototype_name or new_typeinfo.state ~= old_typeinfo.state then
        local srt
        local old_game_object = self.game_object
        if old_game_object then
            srt = world:entity(old_game_object.root).scene.srt
            old_game_object:remove()
        end

        local prototype_name = t.prototype_name or self.prototype_name
        local state = new_typeinfo.state
        local color = new_typeinfo.color

        local typeobject = iprototype:queryByName("entity", prototype_name)
        local game_object = igame_object.create(typeobject.model, state, color, self.id)
        set_srt(world:entity(game_object.root), srt)

        self.game_object, self.prototype_name = game_object, prototype_name
    else
        local game_object = self.game_object
        if new_typeinfo.state == "translucent" and new_typeinfo.color and not math3d.isequal(old_typeinfo.color, new_typeinfo.color) then
            game_object:send("set_material_property", "u_basecolor_factor", new_typeinfo.color)
        end
    end

    if new_typeinfo.block_color == CONSTRUCT_BLOCK_COLOR_INVALID and self.block_entity_object then
        self.block_entity_object:remove()
        self.block_entity_object = nil
    end

    if new_typeinfo.block_color and self.block_entity_object then
        if new_typeinfo.block_edge_size then
            self.block_entity_object:remove()
            local typeobject = iprototype:queryByName("entity", self.prototype_name)
            local block_pos = math3d.ref(math3d.add(math3d.vector(self:get_position()), {0, 1.0, 0}))
            local rotation = get_rotation(self)
            self.block_entity_object = create_block(new_typeinfo.block_color, new_typeinfo.block_edge_size, typeobject.area, block_pos, rotation)
        else
            self.block_entity_object:send("set_material_property", "u_color", new_typeinfo.block_color)
        end
    end

    self.type = t.type or self.type

    -- 将流体图标放至渲染队列尾部, 确保画在最上方
    if self.fluid_icon_entity_object then
        self.fluid_icon_entity_object:send("update_render_object")
    end
end

local function update_fluid(self, fluid_name)
    print("update_fluid", fluid_name)
    if self.fluid_name == fluid_name then
        return
    end
    self.fluid_name = fluid_name

    if self.fluid_icon_entity_object then
        self.fluid_icon_entity_object:remove()
        self.fluid_icon_entity_object = nil
    end

    if self.fluid_name == "" then
        return
    end

    local typeobject = iprototype:queryByName("fluid", fluid_name)
    self.fluid_icon_entity_object = create_texture_plane_entity("/pkg/vaststars.resources/textures/canvas.texture", get_canvas_rect(typeobject.icon), {w=1024, h=1024}, self:get_position())
end

local function attach(self, ...)
    self.game_object:attach(...)
end

local function detach(self, ...)
    self.game_object:detach(...)
end

local function animation_update(self, ...)
    self.game_object:animation_update(...)
end

-- init = {
--     prototype_name = prototype_name,
--     type = xxx,
--     position = position,
--     dir = 'N',
-- }
return function (init)
    local typeobject = iprototype:queryByName("entity", init.prototype_name)
    local typeinfo = assert(typeinfos[init.type], ("invalid type `%s`"):format(init.type))

    local vsobject_id = gen_id()
    local game_object = assert(igame_object.create(typeobject.model, typeinfo.state, typeinfo.color, vsobject_id))
    iom.set_position(world:entity(game_object.root), init.position)
    iom.set_rotation(world:entity(game_object.root), rotators[init.dir])

    local block_pos = math3d.ref(math3d.add(math3d.vector(init.position), {0, 1.0, 0}))
    local block_entity_object = create_block(typeinfo.block_color, typeinfo.block_edge_size, typeobject.area, block_pos, rotators[init.dir])

    local vsobject = {
        id = vsobject_id,
        prototype_name = init.prototype_name,
        type = init.type,
        fluid_name = init.fluid_name or "",

        game_object = game_object,
        block_entity_object = block_entity_object,
        fluid_icon_entity_object = nil,

        --
        update = update,
        update_fluid = update_fluid,
        set_position = set_position,
        get_position = get_position,
        set_dir = set_dir,
        remove = remove,
        attach = attach,
        detach = detach,
        animation_update = animation_update,
    }
    return vsobject
end
