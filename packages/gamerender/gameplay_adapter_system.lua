local ecs = ...
local world = ecs.world
local w = world.w

import_package "vaststars.prototype"
local gameplay = import_package "vaststars.gameplay"
local create_gameplay_world = gameplay.createWorld
local set_road_mb = world:sub {"gameplay_adapter_system", "set_road"}
local ui_get_entity_properties = world:sub {"ui", "GET_DATA", "entity_properties"}

local gameplay_adapter_system = ecs.system "gameplay_adapter_system"
local igameplay_adapter = ecs.interface "igameplay_adapter"

local function packCoord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y << 8)
end

local function unpackCoord(v)
    return v >> 8, v & 0xFF
end

function gameplay_adapter_system:init_world()
    ecs.create_entity({
        policy = {
            "vaststars.gamerender|gameplay_adapter",
        },
        data = {
            gameplay_world = create_gameplay_world(), -- todo
            gameplay_road_entities = {},
        }
    })
end

do
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

    local function get_entity(x, y)
        local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in gameplay_road_entities:in")
        if not gameplay_adapter then
            return
        end

        local gameplay_ecs = gameplay_adapter.gameplay_world.ecs
        for v in gameplay_ecs:select "entity:in" do
            if v.entity.x == x and v.entity.y == y then
                local e = deepcopy(gameplay_ecs:readall(v))
                e[1] = nil
                e[2] = nil
                return e
            end
        end
    end

    function gameplay_adapter_system:data_changed()
        local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")
        if not gameplay_adapter then
            return
        end

        local gameplay_world = gameplay_adapter.gameplay_world
        gameplay_world:update()

        for _, _, _, x, y in ui_get_entity_properties:unpack() do
            local e = get_entity(x, y)
            if e then
                local pt = gameplay.query(e.entity.prototype)

                local t = {}
                t.name = pt.name
                if e.fluidbox and e.fluidbox.fluid ~= 0 then
                    local pt = gameplay.query(e.fluidbox.fluid)
                    t.fluid_name = pt.name

                    local r = gameplay_world:fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
                    if r then
                        t.fluid_volume = r.volume / r.multiple
                    end
                end
                world:pub {"ui_message", "entity_properties", t}
            end
        end
    end
end

function gameplay_adapter_system:entity_ready()
    local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in gameplay_road_entities:in")
    if not gameplay_adapter then
        return
    end

    local gameplay_ecs = gameplay_adapter.gameplay_world.ecs
    for _, _, coord, road_type in set_road_mb:unpack() do
        local e = gameplay_adapter.gameplay_road_entities[coord]
        if e then
            gameplay_ecs:remove(e)
        end

        local ref = {}
        gameplay_ecs:new {
            road = {
                coord = coord,
                road_type = road_type,
            },
            reference = ref,
        }
        gameplay_adapter.gameplay_road_entities[coord] = ref
    end
end

function igameplay_adapter.set_road(x, y, road_type)
    local t = {
        ['N'] = 0,
        ['E'] = 1,
        ['S'] = 2,
        ['W'] = 3,
    }

    local tr = {
        ['L'] = 0,
        ['I'] = 1,
        ['U'] = 2,
        ['T'] = 3,
        ['X'] = 4,
        ['O'] = 5,
    }

    local coord = packCoord(x, y)
    world:pub {"gameplay_adapter_system", "set_road", coord, tr[road_type:sub(1, 1)] << 8 | t[road_type:sub(2, 2)]}
end

do
    local create_entity_cache = {}
    local function create(world, prototype, entity)
        if not create_entity_cache[prototype] then
            create_entity_cache[prototype] = world:create_entity(prototype)
            if not create_entity_cache[prototype] then
                log.error(("failed to create entity `%s`"):format(prototype))
                return
            end
        end
        return create_entity_cache[prototype](entity)
    end

    local function has_entity(x, y)
        local e = w:singleton("gameplay_world", "gameplay_world:in")
        if not e then
            log.error("failed to get gameplay_world")
            return false
        end

        local gameplay_ecs = e.gameplay_world.ecs
        for e in gameplay_ecs:select "entity:in" do
            if x == e.entity.x and e.entity.y == y then
                return true
            end
        end
        return false
    end

    local function isFluidId(id)
        return id & 0x0C00 == 0x0C00
    end

    local function get_fluid_list(fluidboxes, classify, s)
        local lst = fluidboxes[classify]
        assert(lst)

        local r = {}
        for idx = 1, #s//4 do
            local id = string.unpack("<I2I2", s, 4*idx-3)
            if isFluidId(id) then
                local pt = gameplay.query(id)
                r[#r + 1] = {pt.name, 0}
            end
        end
        return r
    end

    local init_func = {}
    init_func["assembling"] = function(pt, entity)
        if not pt.recipe then
            log.error(("can not found recipe `%s`"):format(pt.name))
            return entity
        end
        local r = igameplay_adapter.query("recipe", pt.recipe)

        local output = get_fluid_list(pt.fluidboxes, "output", r.results)
        if #output > 0 then
            entity.fluids = {
                output = output
            }
        end

        return entity
    end

    local function init(prototype, entity)
        local pt = igameplay_adapter.query("entity", prototype)
        local func

        for _, entity_type in ipairs(pt.type) do
            func = init_func[entity_type]
            if func then
                entity = func(pt, entity)
            end
        end
        return entity
    end

    function igameplay_adapter.create_entity(game_object)
        w:sync("prototype:in x:in y:in dir:in fluid?in", game_object)

        if has_entity(game_object.x, game_object.y) then
            log.error(("already create entity(%s, %s)"):format(game_object.x, game_object.y))
            return
        end

        local e = w:singleton("gameplay_world", "gameplay_world:in")
        if not e then
            log.error("failed to create entity")
            return
        end

        local prototype = game_object.prototype
        local gpworld = e.gameplay_world
        local gpentitiy = {
            x = game_object.x,
            y = game_object.y,
            dir = game_object.dir,
            fluid = game_object.fluid,
        }

        gpentitiy = init(game_object.prototype, gpentitiy)
        create(gpworld, prototype, gpentitiy)
        gpworld:build()
    end
end

function igameplay_adapter.remove_entity(x, y)
    local e = w:singleton("gameplay_world", "gameplay_world:in")
    if not e then
        log.error("failed to create entity")
        return
    end

    local gameplay_ecs = e.gameplay_world.ecs

    for e in gameplay_ecs:select "entity:in" do
        if x == e.entity.x and e.entity.y == y then
            gameplay_ecs:remove(e)
        end
    end
end

function igameplay_adapter.world()
    local e = w:singleton("gameplay_world", "gameplay_world:in")
    if not e then
        log.error("failed to create entity")
        return
    end

    return e.gameplay_world
end

function igameplay_adapter.pack_coord(x, y)
    return packCoord(x, y)
end

function igameplay_adapter.unpack_coord(v)
    return unpackCoord(v)
end

function igameplay_adapter.query(maintype, prototype)
    return gameplay.queryByName(maintype, prototype)
end

function igameplay_adapter.prototype_name()
    return gameplay.prototype_name
end