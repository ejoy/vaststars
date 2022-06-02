local function isTag(c)
    return c.type == nil and c[1] == nil
end

local function loadComponents(filename)
    local components = {}
    local function component(name)
        return function (object)
            object.name = name
            components[name] = object
            components[#components+1] = object
        end
    end
    local env = {
        require = function () return component end
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
        return "struct "..typename
    end
    return assert(TYPENAMES[typename])
end

local function writeEntityH(components)
    local out = {}
    local function write(line)
        out[#out+1] = line
    end

    write "#pragma once"
    write ""
    write "#include <stdint.h>"
    write ""

    for _, c in ipairs(components) do
        if isTag(c) then
            write("struct "..c.name.." {};")
            write ""
        else
            write("struct "..c.name.." {")
            for _, field in ipairs(c) do
                local name, typename, n = field:match "^([%w_]+):(%w+)%[(%d+)%]$"
                if name == nil then
                    name, typename = field:match "^([%w_]+):(%w+)$"
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

    write "template <typename T> struct component {};"
    write ""
    for i, c in ipairs(components) do
        write("template <> struct component<"..c.name.."> {")
        write("\tstatic inline const int id = "..i..";")
        write("\tstatic inline const char name[] = \""..c.name.."\";")
        write "};"
        write ""
    end

    return table.concat(out, "\n")
end

local components = loadComponents "packages/gameplay/init/component.lua"
local data = writeEntityH(components)

local f <close> = assert(io.open("clibs/gameplay/src/core/entity.h", "w"))
f:write(data)
