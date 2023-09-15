package.path = "engine/?.lua"
require "bootstrap"
import_package "ant.window".start {
    import = {
        "@vaststars.mod.test",
    },
    pipeline = {
        "init",
        "update",
        "exit",
    },
    feature = {
        "ant.efk",
        "ant.animation",
        "ant.landform",
    },
    system = {
        "vaststars.mod.test|init_system",
    },
    policy = {
        "ant.render|render",
        "ant.render|render_queue",
    }
}
