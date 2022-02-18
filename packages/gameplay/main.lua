local createWorld = require "world"
local status = require "status"

require "init"

return {
    createWorld = createWorld,
    query = require "prototype".queryById,
    queryByName = require "prototype".query,
    prototype_name = status.prototype_name,
    system = require "register.system",
    csystem = require "register.csystem",
    prototype = require "register.prototype",
    pipeline = require "register.pipeline",
}
