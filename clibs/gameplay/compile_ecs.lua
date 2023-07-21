local function isTag(c)
    return c.type == nil and c[1] == nil
end

local function loadComponents(filename)
    local components = {}
    local def = {}
    function def.component(name)
        return function (object)
            object.name = name
            components[name] = object
            components[#components+1] = object
        end
    end
    function def.type(name)
        return function (object)
            components[name] = object
        end
    end
    local env = {
        require = function () return def end
    }
    assert(loadfile(filename, "t", env))()
    return components
end

local TYPENAMES <const> = {
    int = "int32_t",
    dword = "uint32_t",
    word = "uint16_t",
    byte = "uint8_t",
    float = "float",
}

local function TypeName(components, typename)
    if components[typename] then
        return typename
    end
    return TYPENAMES[typename] or typename
end

local function writeEntityH(components)
    local out = {}
    local function write(line)
        out[#out+1] = line
    end

    write "#pragma once"
    write ""
    write "#include \"ecs/select.h\""
    write "#include \"util/component_user.h\""
    write "#include <stdint.h>"
    write ""
    write "constexpr int _component_start_id_ = __COUNTER__ + 2;"
    write ""
    write "#define component(NAME, DECL) \\"
    write "namespace vaststars::ecs { \\"
    write "using NAME = DECL; \\"
    write "} \\"
    write "template <> constexpr int ecs_api::component_id<vaststars::ecs::NAME> = __COUNTER__ - _component_start_id_;"
    write ""
    write "#define tag(NAME) component(NAME, struct {})"
    write ""
    write "component(eid, uint64_t)"
    write "tag(REMOVED)"
    for _, c in ipairs(components) do
        if isTag(c) then
            write(("tag(%s)"):format(c.name))
        else
            write(("component(%s, struct {"):format(c.name))
            for _, field in ipairs(c) do
                local name, typename, n = field:match "^([%w_]+):([^%]]+)%[(%d+)%]$"
                if name == nil then
                    name, typename = field:match "^([%w_]+):(.+)$"
                end
                if n then
                    write(("\t%s %s[%s];"):format(TypeName(components, typename), name, n))
                else
                    write(("\t%s %s;"):format(TypeName(components, typename), name))
                end
            end
            write "})"
        end
    end
    write ""
    write "#undef ecs_component"
    write "#undef ecs_tag"
    write ""
    write "using namespace vaststars;"
    write "static_assert(ecs_api::component_id<ecs::eid> == ecs_api::EntityID);"
    write ""


    return table.concat(out, "\n")
end

local components = loadComponents "startup/pkg/vaststars.gameplay/init/component.lua"
local data = writeEntityH(components)

local f <close> = assert(io.open("clibs/gameplay/src/util/component.h", "w"))
f:write(data)
