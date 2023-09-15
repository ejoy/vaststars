package.path = "engine/?.lua"
require "bootstrap"
import_package "ant.window".start {
    import = {
        "@ant.render",
    },
    feature = {
        "vaststars.mod.test",
        "ant.animation",
        "ant.camera|camera_controller",
        "ant.efk",
        "ant.landform",
        "ant.objcontroller|pickup",
        "mod.billboard",
        "mod.printer",
    },
    policy = {
        "ant.render|render",
        "ant.render|render_queue",
    }
}
