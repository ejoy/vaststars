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
    write "namespace vaststars {"
    write ""
    write "namespace ecs {"
    write ""
    write "using eid = uint64_t;"
    write "struct REMOVED {};"
    write ""

    for _, c in ipairs(components) do
        if isTag(c) then
            write("struct "..c.name.." {};")
            write ""
        else
            write("struct "..c.name.." {")
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
            write "};"
            write ""
        end
    end
    write ""
    write "}"
    write ""
    write "}"
    write ""
    write "using namespace vaststars;"
    write ""

    write "template <> struct ecs_api::component_meta<ecs::eid> {"
    write "\tstatic constexpr unsigned id = 0xFFFFFFFF;"
    write "};"
    write "template <> struct ecs_api::component_meta<ecs::REMOVED> {"
    write "\tstatic constexpr unsigned id = 0;"
    write "};"
    write ""
    write "namespace ecs_api {"
    write ""
    write "#define ECS_COMPONENT(NAME, ID) \\"
    write "template <> struct component_meta<ecs::NAME> { \\"
    write "\tstatic constexpr unsigned int id = ID; \\"
    write "};"
    write ""
    for i, c in ipairs(components) do
        write(("ECS_COMPONENT(%s,%d)"):format(c.name, i))
    end
    write ""
    write "#undef ECS_COMPONENT"
    write ""
    write "}"
    write ""

    return table.concat(out, "\n")
end

local components = loadComponents "startup/pkg/vaststars.gameplay/init/component.lua"
local data = writeEntityH(components)

local f <close> = assert(io.open("clibs/gameplay/src/util/component.h", "w"))
f:write(data)
