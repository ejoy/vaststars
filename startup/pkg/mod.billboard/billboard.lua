local ecs   = ...
local world = ecs.world
local w     = world.w

local imaterial = ecs.require "ant.asset|material"

local bb_sys = ecs.system "billboard_system"

local math3d    = require "math3d"
local bgfx      = require "bgfx"

local renderpkg = import_package "ant.render"
local layoutmgr = renderpkg.layoutmgr
local assetmgr  = import_package "ant.asset"

local billboard_base_table = {}
local cur_base_id = 1

local layout    = layoutmgr.get "p3|t2"

local function create_billboard_entity(srt, texture, render_layer)
    local eid = ecs.create_entity{
        policy = {
            "ant.render|simplerender",
            "mod.billboard|billboard"
        },
        data = {
            billboard = true,
            scene = srt,
            visible_state = "main_view",
            material = "/pkg/mod.billboard/assets/billboard.material",
            simplemesh = {
                vb = {
                    start = 0,
                    num = 4,
                    handle = bgfx.create_vertex_buffer(
                        bgfx.memory_buffer("fffff", {
                            -1, -1,  0,  0,  1,
                            -1,  1,  0,  0,  0 ,
                             1, -1,  0,  1,  1,
                             1,  1,  0,  1,  0,
                        }),
                        layout.handle
                    )
                },
            },
            render_layer = render_layer,
            on_ready = function (e)
                local texobj = {
                    stage = 0,
                    texture = texture,
                    type = 't',
                    value = assetmgr.resource(texture).id
                }
                imaterial.set_property(e, "s_basecolor", texobj)
            end
        }
    }
    return eid
end

local ibillboard = {}

function ibillboard.create_billboard_base(billboard_bases)
    local id_table = {}
    for _, bbs in pairs(billboard_bases) do
        id_table[#id_table+1] = cur_base_id
        local new_billboard_base = {
            idx = cur_base_id,
            cur_sub_idx = 1
        }
        local srt, tex, render_layer = bbs.srt, bbs.texture, bbs.render_layer
        local eid = create_billboard_entity(srt, tex, render_layer)
        new_billboard_base.eid = eid
        billboard_base_table[cur_base_id] = new_billboard_base
        cur_base_id = cur_base_id + 1
    end
    return id_table
end

function ibillboard.remove_billboard_base(id_table)
    for _, idx in pairs(id_table) do
        for bidx, bbs in pairs(billboard_base_table) do
            if bbs.idx == idx then
                w:remove(bbs.eid)
                billboard_base_table[bidx] = nil
            end
        end
    end
end


function bb_sys:camera_usage()
    for e in w:select "billboard render_object:update scene:update" do

        local mq = w:first("main_queue render_target:in camera_ref:in")
        local ce = world:entity(mq.camera_ref, "camera:in")
        local camera_worldmat = math3d.inverse(ce.camera.viewmat)
        local right = math3d.index(camera_worldmat, 1)
        local up = math3d.index(camera_worldmat, 2)
        local dir = math3d.index(camera_worldmat, 3)
        local obj_t = e.scene.t
        local obj_worldmat=math3d.matrix{
            math3d.index(right,1),math3d.index(right,2),math3d.index(right,3),math3d.index(right,4),
            math3d.index(up,1),math3d.index(up,2),math3d.index(up,3),math3d.index(up,4),
            math3d.index(dir,1),math3d.index(dir,2),math3d.index(dir,3),math3d.index(dir,4),
            math3d.index(obj_t,1),math3d.index(obj_t,2),math3d.index(obj_t,3),math3d.index(obj_t,4),
        } 

        math3d.unmark(e.scene.worldmat)
        e.scene.worldmat = math3d.mark(obj_worldmat)

        local ro = e.render_object
        ro.worldmat = e.scene.worldmat
    end
end

return ibillboard
