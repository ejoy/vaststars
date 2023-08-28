#include <bgfx_shader.sh>
#include <bgfx_compute.sh>
#include <shaderlib.sh>
#include "common/camera.sh"
#include "common/transform.sh"
#include "common/utils.sh"
#include "common/cluster_shading.sh"
#include "common/constants.sh"
#include "common/uvmotion.sh"
#include "pbr/lighting.sh"
#include "default/inputs_structure.sh"

#include "pbr/material_default.sh"

uniform vec4 u_construct_color;
uniform vec4 u_printer_factor;
#define u_building_offset   u_printer_factor.x
#define u_building_topmost  u_printer_factor.y

void CUSTOM_FS_FUNC(in FSInput fsinput, inout FSOutput fsoutput)
{
    if(fsinput.pos.y > (u_building_topmost))
        discard;
    
    int building;
    if(fsinput.pos.y > u_building_topmost - u_building_offset){
        building = 1;
    } else{
        building = 0;
    }

    if(building) {
        fsoutput.color = u_construct_color;
    } else {
        material_info mi = (material_info)0;
        default_init_material_info(fsinput, mi);
        build_material_info(mi);
        if (mi.NdotV < 0){
            fsoutput.color = u_construct_color;
        } else {
            fsoutput.color = compute_lighting(mi);
        }
    }
}