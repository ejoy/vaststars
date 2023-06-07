local ecs   = ...
local world = ecs.world
local w     = world.w
local imaterial     = ecs.import.interface "ant.asset|imaterial"
local math3d        = require "math3d"
local init_system = ecs.system "init_system"

function init_system:entity_init()
    for e in w:select "INIT crack:update eid:in render_layer:in scene:in" do
        assert(e.crack and e.crack.crack_color and e.crack.crack_emissive)
        local eid = ecs.create_entity{
            policy = {
                "ant.scene|scene_object",
                "ant.render|render",
            },
            data = {
                scene = {s = e.scene.s, r = e.scene.r, t = e.scene.t},
                mesh  = "/pkg/mod.crack/assets/shapes/crack.glb|meshes/Plane_P1.meshbin",
                material    = "/pkg/mod.crack/assets/crack_color.material",
                visible_state = "main_view|selectable",
                render_layer = e.render_layer,
                on_ready = function(ee)
                    imaterial.set_property(ee, "u_crack_color", math3d.vector(e.crack.crack_color))
                    imaterial.set_property(ee, "u_basecolor_factor", math3d.vector(e.crack.crack_emissive))
                end
            },
        }  
        e.crack.eid = eid
    end
end

function init_system:entity_remove()
    for e in w:select "REMOVED crack:in" do
        assert(e.crack and e.crack.eid)
        w:remove(e.crack.eid)
    end
end