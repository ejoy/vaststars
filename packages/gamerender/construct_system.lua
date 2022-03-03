local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"
local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local iinput = ecs.import.interface "vaststars.input|iinput"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iui = ecs.import.interface "vaststars.ui|iui"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local iroad = ecs.import.interface "vaststars.gamerender|iroad"
local ipipe = ecs.import.interface "vaststars.gamerender|ipipe"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local hwi  = import_package "ant.hwi"

local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local entities_cfg = import_package "vaststars.config".entity
local backers_cfg = import_package "vaststars.config".backers
local fluid_list_cfg = import_package "vaststars.config".fluid_list
local dir = require "dir"
local dir_rotate = dir.rotate
local dir_offset_of_entry = dir.offset_of_entry

local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}
local CONSTRUCT_WHITE_BASIC_COLOR <const> = {50.0, 50.0, 50.0, 0.8}
local DISMANTLE_YELLOW_BASIC_COLOR <const> = {50.0, 50.0, 0.0, 0.8}

local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工

local ui_dismantle_begin_mb = world:sub {"ui", "construct", "dismantle_begin"}       -- 拆除模式
local ui_dismantle_complete_mb = world:sub {"ui", "construct", "dismantle_complete"} -- 开始拆除

local ui_cancel = world:sub {"ui", "construct", "cancel"} -- 返回

local ui_fluidbox_construct_mb = world:sub {"ui", "construct", "fluidbox_construct"}
local ui_fluidbox_update_mb = world:sub {"ui", "construct", "fluidbox_update"}

local ui_get_fluid_category = world:sub {"ui", "GET_DATA", "fluid_category"}
local pickup_show_ui_mb = world:sub {"pickup_mapping", "pickup_show_ui"}
local pickup_disassemble_mb = world:sub {"pickup_mapping", "disassemble"}
local pickup_pipe_mb = world:sub {"pickup_mapping", "pipe"} -- 建造好的水管
local pickup_construct_pipe_mb = world:sub {"pickup_mapping", "construct_pipe"} -- 建造中的水管

local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_sys = ecs.system "construct_system"
local pickup_mapping_canvas_mb = world:sub {"pickup_mapping", "canvas"}
local pickup_mb = world:sub {"pickup"}
local vector2 = require "vector2"

local function deepcopy(t)
    local r = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            r[k] = deepcopy(v)
        else
            r[k] = v
        end
    end
    return r
end

local get_fluid_category; do
    local function is_type(prototype, t)
        for _, v in ipairs(prototype.type) do
            if v == t then
                return true
            end
        end
        return false
    end

    local t = {}
    for _, v in pairs(igameplay_adapter.prototype_name()) do
        if is_type(v, "fluid") then
            for _, c in ipairs(v.catagory) do
                t[c] = t[c] or {}
                t[c][#t[c]+1] = {id = v.id, name = v.name, icon = v.icon}
            end
        end
    end

    local r = {}
    for catagory, v in pairs(t) do
        r[#r+1] = {catagory = catagory, icon = fluid_list_cfg[catagory].icon, pos = fluid_list_cfg[catagory].pos, fluid = v}
        table.sort(v, function(a, b) return a.id < b.id end)
    end
    table.sort(r, function(a, b) return a.pos < b.pos end)

    -- = {{catagory = xxx, icon = xxx, fluid = {{id = xxx, name = xxx, icon = xxx}, ...} }, ...}
    function get_fluid_category()
        return r
    end
end

local function set_constructing_entity(x, y, prototype)
    local e = w:singleton("constructing_entity", "constructing_entity:in")
    if not e then
        log.error("Can not found constructing_entity")
        return
    end

    e.constructing_entity[x] = e.constructing_entity[x] or {}
    assert(e.constructing_entity[x][y] == nil)
    e.constructing_entity[x][y] = prototype
    w:sync("constructing_entity:out", e)
end

local function get_constructing_entity(x, y)
    local e = w:singleton("constructing_entity", "constructing_entity:in")
    if not e then
        log.error("Can not found constructing_entity")
        return
    end

    if not e.constructing_entity[x] then
        return
    end
    return e.constructing_entity[x][y]
end

local function clear_constructing_entity()
    local e = w:singleton("constructing_entity", "constructing_entity:in")
    if not e then
        log.error("Can not found constructing_entity")
        return
    end
    e.constructing_entity = {}
    w:sync("constructing_entity:out", e)
end

local function set_cur_edit_mode(edit_mode)
    local e = w:singleton("cur_edit_mode", "cur_edit_mode:in")
    if not e then
        log.error("Can not found cur_edit_mode")
        return
    end

    e.cur_edit_mode = edit_mode
    w:sync("cur_edit_mode:out", e)
end

local function get_cur_edit_mode()
    local e = w:singleton("cur_edit_mode", "cur_edit_mode:in")
    if not e then
        log.error("Can not found cur_edit_mode")
        return
    end
    return e.cur_edit_mode
end

local check_construct_detector; do
    local base_path = fs.path('/pkg/vaststars.gamerender/construct_detector/')
    local construct_detectors = {}
    for f in fs.pairs(base_path) do
        local detector = fs.relative(f, base_path):stem():string()
        construct_detectors[detector] = ecs.require(('construct_detector.%s'):format(detector))
    end

    local function get_entity(x, y)
        local e = w:singleton("gameplay_world", "gameplay_world:in")
        if not e then
            log.error("can not found gameplay_world")
            return
        end

        local ecs = e.gameplay_world.ecs
        for v in ecs:select "entity:in" do
            if v.entity.x == x and v.entity.y == y then
                return v.entity.prototype
            end
        end

        return get_constructing_entity(x, y)
    end

    function check_construct_detector(detectors, x, y, dir, area)
        local func
        for _, v in ipairs(detectors) do
            func = construct_detectors[v]
            if not func(get_entity, x, y, dir, area) then
                return false
            end
        end
        return true
    end
end

local function replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/construct.material"
            end
        end
    end

    return template
end

local function update_basecolor(game_object, basecolor_factor)
    local prefab = igame_object.get_prefab(game_object)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = world:entity(eid)
        if not e then
            log.error(("can not found entity `%s`"):format(eid))
            goto continue
        end

        if e.material then
            imaterial.set_property(e, "u_basecolor_factor", basecolor_factor)
        end
        ::continue::
    end
end

local function update_basecolor_by_pos(game_object)
    local basecolor_factor
    local prefab = igame_object.get_prefab(game_object)
    local position = math3d.tovalue(iom.get_position(world:entity(prefab.root)))

    if game_object.construct_detector then
        local entity = igameplay_adapter.query("entity", game_object.prototype)
        local coord = iterrain.get_coord_by_position(position)
        if not check_construct_detector(game_object.construct_detector, coord[1], coord[2], game_object.dir, entity.area) then
            basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
        else
            basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
        end
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end
    update_basecolor(game_object, basecolor_factor)
end

local construct_button_canvas_items = {}
local show_construct_button, hide_construct_button; do
    local function is_fluidbox(type)
        for _, t in ipairs(type) do
            if t == "fluidbox" then
                return true
            end
        end
        return false
    end

    local UP_LEFT <const> = vector2.UP_LEFT
    local UP_RIGHT <const> = vector2.UP_RIGHT
    local DOWN <const> = vector2.DOWN
    local RIGHT <const> = vector2.RIGHT

    local coord_offset = {
        {
            name = "confirm.png",
            coord_func = function(x, y, area)
                return x + UP_LEFT[1], y + UP_LEFT[2]
            end,
            event = function()
                local prefab_object
                for game_object in w:select "constructing type:in game_object_id:in" do
                    if is_fluidbox(game_object.type) then
                        world:pub {"ui_message", "show_set_fluidbox", true}
                    else
                        prefab_object = igame_object.get_prefab_object(game_object)
                        prefab_object:send("confirm_construct")
                    end
                end
            end
        },
        {
            name = "cancel.png",
            coord_func = function(x, y, area)
                local width = igameplay_adapter.unpack_coord(area)
                return x + UP_RIGHT[1] * width, y + UP_RIGHT[2]
            end,
            event = function()
                local prefab_object
                for game_object in w:select "constructing" do
                    hide_construct_button()
                    prefab_object = igame_object.get_prefab_object(game_object)
                    prefab_object:remove()
                end
            end,
        },
        {
            name = "rotate.png",
            coord_func = function(x, y, area)
                local dx, dy
                local width, height = igameplay_adapter.unpack_coord(area)
                -- 针对建筑宽度大于 1 的特殊处理
                if width > 1 then
                    if width % 2 == 0 then
                        x = x + RIGHT[1] * ((width - 1) // 2)
                        y = y + DOWN[2] * height
                        dx = x + RIGHT[1]
                        dy = y + DOWN[2] * height
                        return x, y, dx, dy
                    else
                        dx = x + RIGHT[1] * (width // 2)
                        dy = y + DOWN[2] * height
                        return dx, dy
                    end
                else
                    return x + DOWN[1], y + DOWN[2]
                end
            end,
            event = function()
                local prefab_object
                for game_object in w:select "constructing dir:in" do
                    game_object.dir = dir_rotate(game_object.dir, -1)
                    w:sync("dir:out", game_object)
                    prefab_object = igame_object.get_prefab_object(game_object)
                    local rotation = iom.get_rotation(prefab_object.root)
                    local deg = math.deg(math3d.tovalue(math3d.quat2euler(rotation))[2])
                    iom.set_rotation(prefab_object.root, math3d.quaternion{axis=mc.YAXIS, r=math.rad(deg - 90)})
                    update_basecolor_by_pos(game_object)
                end
            end,
        },
    }

    function hide_construct_button()
        for _, v in pairs(construct_button_canvas_items) do
            icanvas.remove_item(v.id)
        end
        construct_button_canvas_items = {}
    end

    function show_construct_button(x, y, area)
        hide_construct_button()

        for _, v in ipairs(coord_offset) do
            local cx, cy, dx, dy = v.coord_func(x, y, area)
            if not iterrain.verify_coord(cx, cy) then
                goto continue
            end

            local pcoord = igameplay_adapter.pack_coord(cx, cy)
            local id
            if dx and dy then
                id = icanvas.add_items(v.name, cx, cy, {t = {5, 0}})
            else
                id = icanvas.add_items(v.name, cx, cy)
            end
            construct_button_canvas_items[pcoord] = {id = id, event = v.event}

            if dx and dy then
                local pcoord = igameplay_adapter.pack_coord(dx, dy)
                construct_button_canvas_items[pcoord] = {id = id, event = v.event}
            end
            ::continue::
        end
    end
end

local on_prefab_ready; do
    function on_prefab_ready(game_object, prefab)
        update_basecolor_by_pos(game_object)
        show_construct_button(game_object.x, game_object.y, game_object.area)
    end
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(game_object)
        update_basecolor_by_pos(game_object)
    end

    funcs["confirm_construct"] = function(game_object, prefab)
        local position = math3d.tovalue(iom.get_position(world:entity(prefab.root)))
        if game_object.construct_detector then
            local entity = igameplay_adapter.query("entity", game_object.prototype)
            local coord = iterrain.get_coord_by_position(position)
            if not check_construct_detector(game_object.construct_detector, coord[1], coord[2], game_object.dir, entity.area) then
                print("can not construct") -- todo error tips
                return
            end
        end

        update_basecolor(game_object, CONSTRUCT_WHITE_BASIC_COLOR)
        game_object.constructing = false
        game_object.construct = true
        game_object.drapdrop = false
        hide_construct_button()
        set_constructing_entity(game_object.x, game_object.y, game_object.prototype)
    end

    function on_prefab_message(game_object, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(game_object, prefab, ...)
        end
    end
end

function construct_sys:init_world()
    ecs.create_entity {
        policy = {
        },
        data = {
            cur_edit_mode = "",
            constructing_entity = {},
        }
    }
end

function construct_sys:entity_init()
	for e in w:select "INIT x:in y:in area:in prototype:in construct_entity?in constructing:absent construct:absent" do
        if not e.construct_entity then
            iterrain.set_tile_building_type({e.x, e.y}, e.prototype, e.area)
        end
    end

    for e in w:select "INIT set_road_entry:in x:in y:in dir:in area:in" do
        local offset = dir_offset_of_entry(e.dir)
        local width, heigh = igameplay_adapter.unpack_coord(e.area)
        local coord = {
            e.x + offset[1] + (offset[1] * (width // 2)),
            e.y + offset[2] + (offset[2] * (heigh // 2)),
        }

        iroad.set_building_entry(coord, e.dir)
    end
    w:clear "set_road_entry"

    for e in w:select "INIT random_name:in name:out" do
        e.name = backers_cfg[math.random(1, #backers_cfg)]
    end
end

function construct_sys:camera_usage()
    local coord, position
    for _, game_object, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        w:sync("area:in x:in y:in game_object_id:in", game_object)

        local prefab_object = igame_object.get_prefab_object(game_object)
        position = iinput.screen_to_world {mouse_x, mouse_y}
        coord, position = iterrain.adjust_position(math3d.tovalue(position), game_object.area)
        if not coord then
            goto continue
        end

        game_object.x = coord[1]
        game_object.y = coord[2]
        w:sync("x:out y:out", game_object)

        iom.set_position(world:entity(prefab_object.root), position)
        show_construct_button(coord[1], coord[2], game_object.area)
        prefab_object:send("basecolor")
        ::continue::
    end

    local cfg
    for _, _, _, prototype in ui_construct_entity_mb:unpack() do
        cfg = entities_cfg[prototype]
        if cfg then
            for game_object in w:select "constructing:in" do
                w:sync("game_object_id:in", game_object)
                igame_object.get_prefab_object(game_object):remove()
            end

            local f = ("/pkg/vaststars.resources/%s"):format(cfg.prefab)
            local template = replace_material(serialize.parse(f, cr.read_file(f)))
            local prefab = ecs.create_instance(template)

            local pt = igameplay_adapter.query("entity", prototype)
            if not pt then
                log.error(("can not found prototype `%s`"):format(prototype))
                return
            end

            local screen_x, screen_y = hwi.screen_size()
            local coord, position = iterrain.adjust_position(math3d.tovalue(iinput.screen_to_world({screen_x / 2, screen_y / 2})), pt.area)
            iom.set_position(world:entity(prefab.root), position)

            local t = {
                policy = {},
                data = {
                    prototype = prototype,
                    type = pt.type,
                    drapdrop = true,
                    construct_entity = cfg.component,
                    pause_animation = true,
                    dir = 'N',
                    x = coord[1],
                    y = coord[2],
                    construct_prefab = cfg.prefab,
                    area = pt.area,
                    constructing = true,
                    constructing_fluid = {},
                },
            }

            for k, v in pairs(cfg.construct_component) do
                t.data[k] = v
            end

            prefab.on_message = on_prefab_message
            prefab.on_ready = on_prefab_ready
            iprefab_object.create(prefab, t)
        else
            log.error(("Can not found prototype `%s`"):format(prototype))
        end
    end
end

local gameplay = import_package "vaststars.gameplay"

function construct_sys:data_changed()
    for _ in ui_get_fluid_category:unpack() do
        world:pub {"ui_message", "SET_DATA", {["fluid_category"] = get_fluid_category()}}
    end

    for _, _, _, fluidname in ui_fluidbox_construct_mb:unpack() do
        local prefab_object
        for game_object in w:select "constructing constructing_fluid?in game_object_id:in" do
            game_object.constructing_fluid = {fluidname, 0} -- 指定 fluidbox 的流体类型
            w:sync("constructing_fluid?out", game_object)
            prefab_object = igame_object.get_prefab_object(game_object)
            prefab_object:send("confirm_construct")
        end
    end

    for _, _, _, confirm, fluidname in ui_fluidbox_update_mb:unpack() do
        if confirm == "confirm" then
            for game_object in w:select "fluidbox_selected x:in y:in" do
                local pt = gameplay.queryByName("fluid", fluidname)
                if not pt then
                    log.error(("can not found fluid(%s)"):format(fluidname))
                    goto continue
                end

                for v in igameplay_adapter.world().ecs:select "entity:in fluidbox:out" do
                    if v.entity.x == game_object.x and v.entity.y == game_object.y then
                        v.fluidbox.fluid = pt.id
                        v.fluidbox.id = 0
                    end
                end
            end
            igameplay_adapter.world():build()
        end
        world:pub {"ui_message", "show_set_fluidbox", false}
        ::continue::
    end

    -----
    for _ in ui_construct_begin_mb:unpack() do
        set_cur_edit_mode("construct")
    end

    for _ in ui_construct_complete_mb:unpack() do
        for game_object in w:select "construct game_object_id:in" do
            local prefab = igame_object.get_prefab(game_object)
            if not prefab then
                goto continue
            end
            local srt = world:entity(prefab.root).scene.srt

            w:sync("construct_road?in construct_pipe?in dir:in construct_prefab:in construct_entity:in x:in y:in prototype:in area:in constructing_fluid?in", game_object)
            if game_object.construct_road then
                iroad.construct(nil, {game_object.x, game_object.y})
            elseif game_object.construct_pipe then
                ipipe.construct(nil, {game_object.x, game_object.y}, game_object.dir, game_object.constructing_fluid)
            else
                local new_prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format(game_object.construct_prefab))
                iom.set_srt(world:entity(new_prefab.root), srt.s, srt.r, srt.t)
                local template = {
                    policy = {},
                    data = {
                        prototype = game_object.prototype,
                        pause_animation = true,
                        disassemble = true,
                        disassemble_selected = false,
                        x = game_object.x,
                        y = game_object.y,
                        dir = game_object.dir,
                        area = game_object.area,
                        construct_prefab = ("/pkg/vaststars.resources/%s"):format(game_object.construct_prefab),
                        constructing_fluid = game_object.constructing_fluid,
                    }
                }

                for k, v in pairs(game_object.construct_entity) do
                    template.data[k] = v
                end

                new_prefab.on_ready = function(game_object, prefab)
                    igameplay_adapter.create_entity(game_object)
                end
                iprefab_object.create(new_prefab, template)
            end

            -- remove construct entity
            prefab:remove()
            ::continue::
        end

        for game_object in w:select "constructing" do
            local prefab = igame_object.get_prefab(game_object)
            prefab:remove()
        end

        hide_construct_button()

        clear_constructing_entity()
        set_cur_edit_mode("")
    end

    ---
    for _ in ui_dismantle_begin_mb:unpack() do
        set_cur_edit_mode("dismantle")
    end

    for _ in ui_dismantle_complete_mb:unpack() do
        for game_object in w:select "disassemble_selected:in pipe?in road?in x:in y:in area:in" do
            if game_object.pipe then
                ipipe.dismantle(game_object.x, game_object.y)
            elseif game_object.road then
                iroad.dismantle(game_object.x, game_object.y)
            else
                iterrain.set_tile_building_type({game_object.x, game_object.y}, nil, game_object.area)
                igame_object.get_prefab_object(game_object):remove()
                igameplay_adapter.remove_entity(game_object.x, game_object.y)
            end
        end
        set_cur_edit_mode("")
    end

    for _ in ui_cancel:unpack() do
        for game_object in w:select "construct" do
            igame_object.get_prefab_object(game_object):remove()
        end
        for game_object in w:select "disassemble_selected:in" do
            igame_object.get_prefab_object(game_object):remove()
        end
        clear_constructing_entity()
        set_cur_edit_mode("")
    end
end

function construct_sys:after_pickup_mapping()
    for _, _, game_object_eid in pickup_pipe_mb:unpack() do
        local game_object = world:entity(game_object_eid)
        game_object.fluidbox_selected = true

        local fluid_name, fluid_volume
        for e in igameplay_adapter.world().ecs:select "entity:in fluidbox:in" do
            if e.entity.x == game_object.x and e.entity.y == game_object.y then
                local pt = gameplay.query(e.fluidbox.fluid)
                if pt then
                    fluid_name = pt.name
                end

                fluid_volume = 0
                if e.fluidbox and e.fluidbox.fluid ~= 0 then
                    local r = igameplay_adapter.world():fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
                    if r then
                        fluid_volume = r.volume / r.multiple
                    end
                end
            end
        end
        local fluid
        if fluid_name then
            fluid = {fluid_name, fluid_volume}
        else
            log.error(("can not found fluid(%s, %s)"):format(game_object.x, game_object.y))
        end
        world:pub {"ui_message", "show_set_fluidbox", true, fluid}
    end

    for _, _, game_object_eid in pickup_construct_pipe_mb:unpack() do
        local game_object = world:entity(game_object_eid)
        game_object.fluidbox_selected = true
        world:pub {"ui_message", "show_set_fluidbox", true, game_object.constructing_fluid}
    end

    for _, _, game_object_eid in pickup_disassemble_mb:unpack() do
        if get_cur_edit_mode() ~= "dismantle" then
            break
        end
        local game_object = world:entity(game_object_eid)
        game_object.disassemble_selected = not game_object.disassemble_selected

        local t = deepcopy(w:readall(game_object))
        t[1] = nil
        t[2] = nil

        local prefab = igame_object.get_prefab(game_object)
        local position = math3d.tovalue(iom.get_position(prefab.root))
        igame_object.get_prefab_object(game_object):remove()

        local prefab
        if game_object.disassemble_selected then
            local template = replace_material(serialize.parse(game_object.construct_prefab, cr.read_file(game_object.construct_prefab)))
            prefab = ecs.create_instance(template)
            prefab.on_ready = function (game_object, prefab)
                iom.set_position(prefab.root, position)
                update_basecolor(game_object, DISMANTLE_YELLOW_BASIC_COLOR)
            end

        else
            prefab = ecs.create_instance(game_object.construct_prefab)
            prefab.on_ready = function (game_object, prefab)
                iom.set_position(prefab.root, position)
            end
        end

        local game_object = iprefab_object.create(prefab, {policy = {}, data = t})
        if t.pipe then
            ipipe.update_game_object(t.x, t.y, game_object)
        end
        if t.road then
            iroad.update_game_object(t.x, t.y, game_object)
        end
    end

    local show = false
    local url
    for _, _, entity in pickup_show_ui_mb:unpack() do
        if get_cur_edit_mode() == "" then
            w:sync("pickup_show_ui:in", entity)
            url = entity.pickup_show_ui[1]
            iui.open(url, table.unpack(entity.pickup_show_ui, 2))
        end
    end

    for _ in pickup_mapping_canvas_mb:unpack() do
        if get_cur_edit_mode() == "construct" then
            local pos = iinput.get_mouse_world_position()
            local coord = iterrain.get_coord_by_position(pos)
            local k = igameplay_adapter.pack_coord(coord[1], coord[2])
            local v = construct_button_canvas_items[k]
            if v then
                v.event()
                show = true
            end
        end
    end

    for _ in pickup_mb:unpack() do
        if not show then
            hide_construct_button()
        end
        break
    end
end
