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
#include "pbr/attribute_define.sh"
#include "pbr/attribute_uniforms.sh"
#include "common/default_inputs_structure.sh"
#include "pbr/input_attributes.sh"

uniform vec4 u_construct_color;
uniform vec4 u_printer_factor;
#define u_building_offset   u_printer_factor.x
#define u_building_topmost  u_printer_factor.y

void CUSTOM_FS_FUNC(in FSInput fs_input, inout FSOutput fs_output)
{
    if(fs_input.pos.y > (u_building_topmost))
        discard;
    
    int building;
    if(fs_input.pos.y > u_building_topmost - u_building_offset){
        building = 1;
    } else{
        building = 0;
    }

    if(building) {
        fs_output.color = u_construct_color;
    } else {
        input_attributes input_attribs = (input_attributes)0;
        build_fs_input_attribs(fs_input, input_attribs);
        if (dot(input_attribs.N, input_attribs.V) < 0){
            fs_output.color = u_construct_color;
        } else {
            fs_output.color = compute_lighting(input_attribs);
        }
    }
}