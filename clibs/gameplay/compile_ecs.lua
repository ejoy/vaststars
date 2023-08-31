local function isTag(c)
    return c.type == nil and c[1] == nil
end

local CppType <const> = {
    int8   = "int8_t",
    int16  = "int16_t",
    int32  = "int32_t",
    int64  = "int64_t",
    uint8  = "uint8_t",
    uint16 = "uint16_t",
    uint32 = "uint32_t",
    uint64 = "uint64_t",
    float  = "float",
    bool   = "bool",
}

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
    write "#define component_raw(NAME, DECL) \\"
    write "namespace vaststars::ecs { \\"
    write "using NAME = DECL; \\"
    write "} \\"
    write "template <> constexpr inline int ecs_api::component_id<vaststars::ecs::NAME> = __COUNTER__ - _component_start_id_;"
    write ""
    write "#define component(NAME, DECL) \\"
    write "namespace vaststars::ecs { \\"
    write "struct NAME DECL; \\"
    write "} \\"
    write "template <> constexpr inline int ecs_api::component_id<vaststars::ecs::NAME> = __COUNTER__ - _component_start_id_;"
    write ""
    write "#define tag(NAME) component(NAME, {})"
    write ""
    write "component_raw(eid, uint64_t)"
    write "tag(REMOVED)"
    for _, c in ipairs(components) do
        if isTag(c) then
            write(("tag(%s)"):format(c.name))
        else
            write(("component(%s, {"):format(c.name))
            for _, field in ipairs(c) do
                if field.n then
                    write(("\t%s %s[%s];"):format(CppType[field.typename] or field.typename, field.name, field.n))
                else
                    write(("\t%s %s;"):format(CppType[field.typename] or field.typename, field.name))
                end
            end
            write "})"
        end
    end
    write ""
    write "#undef component"
    write "#undef tag"
    write ""
    write "using namespace vaststars;"
    write "static_assert(ecs_api::component_id<ecs::eid> == ecs_api::COMPONENT::EID);"
    write ""

    return table.concat(out, "\n")
end

local loadComponents = dofile "startup/pkg/vaststars.gameplay/init/component_load.lua"
local components = loadComponents "startup/pkg/vaststars.gameplay/init/component.lua"
local data = writeEntityH(components)

local f <close> = assert(io.open("clibs/gameplay/src/util/component.h", "w"))
f:write(data)
