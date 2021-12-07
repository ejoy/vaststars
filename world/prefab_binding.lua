local ecs = ...
local world = ecs.world
local w = world.w

local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ipickup_mapping = ecs.import.interface "vaststars|ipickup_mapping"

-- assuming that the last template is binding entity
local function on_prefab_ready(prefab)
    local s = #prefab.tag["*"]
    local binding_entity = prefab.tag["*"][s]

    local e
    for i = 1, s - 1 do
        e = prefab.tag["*"][i]
        if not e.scene then
            w:sync("scene:in", e)
        end

        --
        if e.scene.parent == prefab.root.scene.id then
            world:call(e, "set_parent", binding_entity)
        end

        --
        ipickup_mapping.mapping(e.scene.id, binding_entity)
    end
    world:call(binding_entity, "set_parent", nil) -- todo bad teste

    w:sync("prefab_binding_on_ready?in", binding_entity)
    if binding_entity.prefab_binding_on_ready then
        binding_entity.prefab_binding_on_ready(prefab)
    end
end

local on_prefab_message ; do
    local funcs = {}
    funcs["remove"] = function(prefab)
        prefab:remove()

        --
        local s = #prefab.tag["*"]
        local e
        for i = 1, s - 1 do
            e = prefab.tag["*"][i]
            w:sync("scene:in", e)
            ipickup_mapping.unmapping(e.scene.id)
        end
    end

    function on_prefab_message(prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(prefab, ...)
        end       

        local s = #prefab.tag["*"]
        local binding_entity = prefab.tag["*"][s]
        w:sync("prefab_binding_on_message?in", binding_entity)
        if binding_entity.prefab_binding_on_message then
            binding_entity.prefab_binding_on_message(prefab, cmd, ...)
        end
    end
end

local function create(filename, data)
    local template
    if type(filename) ~= "table" then
        template = serialize.parse(filename, cr.read_file(filename))
    else
        template = filename
    end

    template[#template + 1] = data
    local instance = ecs.create_instance(template)

    instance.on_ready = on_prefab_ready
    instance.on_message = on_prefab_message

    if data.data.scene and data.data.scene.srt then -- todo bad teste
        local srt = data.data.scene.srt
        iom.set_srt(instance.root, srt.s, srt.r, srt.t)
    end
    return world:create_object(instance)
end
return create