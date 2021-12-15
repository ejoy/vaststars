local status = require "status"

local m = {}

local unit = status.unit
local id_lookup = status.prototype_id
local name_lookup = status.prototype_name

function m.queryById(name)
	return id_lookup[name]
end

function m.query(maintype, name)
	return name_lookup[maintype.."::"..name]
end

function m.value(unitname, v)
	return unit[unitname].converter(v)
end

return m
