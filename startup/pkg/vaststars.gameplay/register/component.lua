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
	bool   = "byte",
}

local function ExtraSyntax(c, types)
	local r = {}
	for _, field in ipairs(c) do
		if field.n then
			local usertype = types[field.typename]
			if usertype then
				assert(type(usertype) == "table")
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
			local usertype = types[field.typename]
			if usertype then
				if type(usertype) == "table" then
					for _, ufield in ipairs(usertype) do
						r[#r+1] = ("%s_%s:%s"):format(field.name, ufield.name, EcsType[ufield.typename])
					end
				else
					r[#r+1] = ("%s:%s"):format(field.name, EcsType[usertype])
				end
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
