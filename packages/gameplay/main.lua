local game = require "base.game"

require "type.init"

return {
    game = game,
    system = require "base.register.system",
    csystem = require "base.register.csystem",
    prototype = require "base.register.prototype",
}
