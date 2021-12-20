local function isTag(c)
    return c.type == nil and c[1] == nil
end

local function loadComponents(filename)
    local components = {}
    local function component(name)
        return function (object)
            object.name = name
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
    word = "uint16_t",
    byte = "uint8_t",
    float = "float",
}

local function writeEntityH(components)
    local out = {}
    local function write(line)
        out[#out+1] = line
    end

    write "#pragma once"
    write ""
    write "#include <stdint.h>"
    write ""
    write "enum COMPONENT {"
    for i, c in ipairs(components) do
        write(("\t%s_%s = %d,"):format(isTag(c) and "TAG" or "COMPONENT", c.name:upper(), i))
    end
    write "};"
    write ""
    for _, c in ipairs(components) do
        if not isTag(c) then
            write("struct "..c.name.." {")
            for _, field in ipairs(c) do
                local name, typename = field:match "^([%w_]+):(%w+)$"
                write(("\t%s %s;"):format(assert(TYPENAMES[typename]), name))
            end
            write "};"
            write ""
        end
    end

    return table.concat(out, "\n")
end

local components = loadComponents "packages/gameplay/init/component.lua"
local data = writeEntityH(components)

local f <close> = assert(io.open("clibs/gameplay/src/entity.h", "w"))
f:write(data)
