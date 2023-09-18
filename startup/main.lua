package.path = "engine/?.lua"
require "bootstrap"
import_package "ant.window".start {
    import = {
        "@vaststars.gamerender",
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
    }
}
