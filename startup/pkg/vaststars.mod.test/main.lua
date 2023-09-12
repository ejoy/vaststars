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
    system = {
        "vaststars.mod.test|init_system",
    },
    policy = {
        "ant.scene|scene_object",
        "ant.render|render",
        "ant.render|render_queue",
    }
}
