package.path = "engine/?.lua"
require "bootstrap"
for i = 2, #arg do
    load(arg[i])()
end
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
    interface = {
        "ant.objcontroller|iobj_motion",
    },
    policy = {
        "ant.general|name",
        "ant.scene|scene_object",
        "ant.render|render",
        "ant.render|render_queue",
        "ant.objcontroller|pickup",
    }
}
