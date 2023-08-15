local EcsType <const> = {
    int8   = "byte",
    int16  = "word",
    int32  = "int",
    int64  = "int64",
    uint8  = "byte",
    uint16 = "word",
    uint32 = "dword",
    uint64 = "int64",
    float  = "float",
}

local function ExtraSyntax(c, types)
	local r = {}
	for _, field in ipairs(c) do
		if field.n then
			local usertype = types[field.typename]
			if usertype then
				for i = 1, tonumber(field.n) do
					for _, userfield in ipairs(usertype) do
						r[#r+1] = ("%s%d_%s:%s"):format(field.name, i, userfield.name, EcsType[userfield.typename])
					end
				end
			else
				for i = 1, tonumber(field.n) do
					r[#r+1] = ("%s%d:%s"):format(field.name, i, EcsType[field.typename])
				end
			end
		else
			if types[field.typename] then
				r[#r+1] = ("%s:%s"):format(field.name, EcsType[types[field.typename]])
			else
				r[#r+1] = ("%s:%s"):format(field.name, EcsType[field.typename])
			end
		end
	end
	return r
end

local loadComponents = require "init.component_load"
local components, types = loadComponents "/pkg/vaststars.gameplay/init/component.lua"
local syntaxs = {}
for _, component in ipairs(components) do
	local syntax = ExtraSyntax(component, types)
	syntax.name = component.name
	syntaxs[#syntaxs+1] = syntax
end

return syntaxs
