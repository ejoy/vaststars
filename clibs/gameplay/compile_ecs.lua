local function ecs_components(output, namespace, userheader, components)
    local out = {}
    local function writefile(filename)
        local f <close> = assert(io.open(filename, "w"))
        f:write(table.concat(out, "\n"))
        out = {}
    end
    local function write(line)
        out[#out+1] = line
    end
    write "#pragma once"
    write ""
    write "#include \"ecs/select.h\""
    write(("#include \"%s\""):format(userheader))
    write "#include <cstdint>"
    write "#include <tuple>"
    write ""
    write(("namespace %s {"):format(namespace))
    write ""
    write "using eid = uint64_t;"
    write ""
    write "struct REMOVED {};"
    write ""
    for _, info in ipairs(components) do
        local name, type = info[1], info[2]
        if type == "c" then
            local fields = info[3]
            write(("struct %s {"):format(name))
            for _, field in ipairs(fields) do
                write(("\t%s %s;"):format(field[1], field[2]))
            end
            write("};")
            write ""
        elseif type == "raw" then
            local size = info[3]
            write(("struct %s { uint8_t raw[%d]; }"):format(name, size))
            write ""
        elseif type == "tag" then
            write(("struct %s {};"):format(name))
            write ""
        elseif type == "lua" then
            write(("struct %s { unsigned int lua_object; };"):format(name))
            write ""
        elseif type == "int" then
            local field = info[2]
            write(("using %s = %s;"):format(name, field))
            write ""
        end
    end
    write "using _all_ = ::std::tuple<"
    for i = 1, #components-1 do
        local c = components[i]
        write(("\t%s,"):format(c[1]))
    end
    write(("\t%s"):format(components[#components][1]))
    write ">;"
    write ""
    write "}"
    write ""
    write(("namespace component = %s;"):format(namespace))
    write ""
    write "template <>"
    write "constexpr int ecs::component_id<component::eid> = ecs::COMPONENT::EID;"
    write "template <>"
    write "constexpr int ecs::component_id<component::REMOVED> = ecs::COMPONENT::REMOVED;"
    write "template <typename T>"
    write "    requires (ecs::helper::component_has_v<T, component::_all_>)"
    write "constexpr int ecs::component_id<T> = ecs::helper::component_id_v<T, component::_all_>;"
    write ""
    writefile(output)
end

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

local function prebuilt_components(components)
    local out = {}
    for _, c in ipairs(components) do
        if isTag(c) then
            out[#out+1] = {c.name, "tag"}
        else
            local fields = {}
            for _, field in ipairs(c) do
                if field.n then
                    fields[#fields+1] = {
                        CppType[field.typename] or field.typename,
                        ("%s[%s]"):format(field.name, field.n)
                    }
                else
                    fields[#fields+1] = {
                        CppType[field.typename] or field.typename,
                        field.name
                    }
                end
            end
            out[#out+1] = {c.name, "c", fields}
        end
    end
    return out
end

local loadComponents = dofile "startup/pkg/vaststars.gameplay/init/component_load.lua"
local components = loadComponents "startup/pkg/vaststars.gameplay/init/component.lua"

ecs_components(
    "clibs/gameplay/src/util/component.h",
    "vaststars_component",
    "util/component_user.h",
    prebuilt_components(components)
)
