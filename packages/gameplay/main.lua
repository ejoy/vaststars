import_package "vaststars.version"

local createWorld = require "world"

require "init"

local function interface(what)
    return require("interface."..what)
end

return {
    createWorld = createWorld,
    prototype = require "prototype",
    register = {
        system = require "register.system",
        csystem = require "register.csystem",
        prototype = require "register.prototype",
        pipeline = require "register.pipeline",
    },
    interface = interface
}
