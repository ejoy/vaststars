local AntDir = ...
local ecs_components = dofile(AntDir.."/clibs/ecs/ecs_components.lua")

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
