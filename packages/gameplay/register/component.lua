local status = require "status"

return function (name)
	return function (object)
		object.name = name
		status.components[name] = object
	end
end
