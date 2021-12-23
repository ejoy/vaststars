local createWorld = require "world"

require "init"

return {
    createWorld = createWorld,
    query = require "prototype".queryById,
    system = require "register.system",
    csystem = require "register.csystem",
    prototype = require "register.prototype",
    pipeline = require "register.pipeline",
}
