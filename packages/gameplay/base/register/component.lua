local status = require "base.status"

return function (name)
	return function (object)
		object.name = name
		status.components[name] = object
	end
end
