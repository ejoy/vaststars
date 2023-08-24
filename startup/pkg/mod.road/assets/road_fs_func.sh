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
#include "road.sh"

material_info road_material_info_init(vec3 gnormal, vec3 normal, vec4 posWS, vec4 basecolor, vec4 fragcoord, vec4 metallic, vec4 roughness)
{
    material_info mi  = (material_info)0;
    mi.basecolor         = basecolor;
    mi.posWS             = posWS.xyz;
    mi.distanceVS        = posWS.w;
    mi.V                 = normalize(u_eyepos.xyz - posWS.xyz);
    mi.gN                = gnormal;  //geomtery normal
    mi.N                 = normal;

    mi.perceptual_roughness  = roughness;
    mi.metallic              = metallic;
    mi.occlusion         = 1.0;

    mi.screen_uv         = calc_normalize_fragcoord(fragcoord.xy);
    return mi;
}

void CUSTOM_FS_FUNC(in FSInput fsinput, inout FSOutput fsoutput)
{
    float road_type  = fsinput.user0.x;
    float road_shape = fsinput.user0.y;
    float mark_type  = fsinput.user0.z;
    float mark_shape = fsinput.user0.w;

	//t0 1x1 road color/height/normal
	//t1 1x1 mark color/alpha
    const vec2 road_uv  = fsinput.uv0;
    const vec2 mark_uv  = fsinput.user1.xy;

    vec4 road_basecolor = texture2D(s_basecolor, vec3(road_uv, road_shape));

    vec4 mark_basecolor = vec4(0, 0, 0, 0);
    float mark_alpha = 0;
    
    if(mark_type != 0){
        mark_alpha = texture2DArray(s_mark_alpha, vec3(mark_uv, mark_shape));
        if(mark_type == 1){
            mark_basecolor = vec4(0.71484, 0, 0, 1);
        }
        else{
            mark_basecolor = vec4(1, 1, 1, 1);
        }
    }   

    vec3 basecolor = calc_road_mark_blend_color(road_type, road_basecolor, mark_type, mark_basecolor, mark_alpha);

    bool is_road_part = road_type != 0;
    bool is_mark_part = mark_type != 0;
    if(is_road_part && !is_mark_part && road_basecolor.a == 0){
        discard;
    }
    else if(!is_road_part && is_mark_part && mark_alpha == 1){
        discard;
    }
    else if(is_road_part && is_mark_part && road_basecolor.a == 0 && mark_alpha == 1){
        discard;
    }
    else{
        mediump vec4 mrSample = texture2D(s_metallic_roughness, road_uv);
        float roughness = mrSample.g;
        float metallic = mrSample.b;
        material_info mi = road_material_info_init(fsinput.normal, fsinput.normal, fsinput.pos, vec4(basecolor, 1.0), fsinput.frag_coord, metallic, roughness);
        build_material_info(mi);
        fsoutput.color = compute_lighting(mi);
    }
}