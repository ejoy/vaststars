package.path = "engine/?.lua"
require "bootstrap"
import_package "ant.window".start {
    import = {
        "@vaststars.gamerender"
    },
    pipeline = {
        "init",
        "update",
        "exit",
    },
    system = {
        "vaststars.gamerender|init_system",
    },
    policy = {
        "ant.general|name",
        "ant.scene|scene_object",
        "ant.render|render",
        "ant.render|render_queue",
        "ant.objcontroller|pickup",
    }
}
