local status = require "status"

return function (name)
	return function (object)
		object.name = name
		status.components[#status.components+1] = object
	end
end
