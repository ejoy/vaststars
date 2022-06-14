local status = require "status"

local m = {}

local unit = status.unit
local id_lookup = status.prototype_id
local name_lookup = status.prototype_name

function m.queryById(id)
	return id_lookup[id]
end

function m.queryByName(maintype, name)
	return name_lookup[maintype][name]
end

function m.each(maintype)
	return name_lookup[maintype]
end

function m.value(unitname, v)
	return unit[unitname].converter(v)
end

return m
