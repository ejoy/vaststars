local type = require "register.type"

local m = type "item"
    .station_limit "integer"
    .backpack_limit "integer"
    .hub_limit "integer"
    .pile "volume"

function m:preinit(object)
	local w, h, d = object.pile:match "(%d+)x(%d+)x(%d+)"
	if not w then
		return nil, "Need volume *,*"
	end
	w = w + 0
	h = h + 0
	d = d + 0
    return {
        hub_limit = w * h * d
    }
end
