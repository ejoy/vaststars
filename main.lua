package.path = "engine/?.lua"
require "bootstrap"
import_package "ant.window".start {
    import = {
        "@vaststars",
    },
    pipeline = {
        "init",
        "update",
        "exit",
    },
    system = {
        "vaststars|init_system",
    },
    interface = {
        "ant.objcontroller|iobj_motion",
        "ant.animation|ianimation",
        "ant.effekseer|effekseer_playback",
    },
    policy = {
        "ant.general|name",
        "ant.scene|scene_object",
        "ant.render|render",
        "ant.render|render_queue",
        "ant.objcontroller|pickup",
    }
}
