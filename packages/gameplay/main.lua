local createWorld = require "world"

require "init"

return {
    createWorld = createWorld,
    query = require "prototype".queryById,
    queryByName = require "prototype".query,
    system = require "register.system",
    csystem = require "register.csystem",
    prototype = require "register.prototype",
    pipeline = require "register.pipeline",
}
