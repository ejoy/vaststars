package.path = "engine/?.lua"
require "bootstrap"
import_package "ant.window".start {
    import = {
        "@vaststars.gamerender",
        "@ant.render",
    },
    pipeline = {
        "init",
        "update",
        "exit",
    },
    feature = {
        "vaststars.gamerender|engine",
    },
    system = {
        "vaststars.gamerender|init_system",
    },
    policy = {
        "ant.scene|scene_object",
        "ant.render|render",
        "ant.render|render_queue",
        "ant.objcontroller|pickup",
    }
}
