$input v_texcoord0 v_normal v_tangent v_posWS

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
#include "pbr/indirect_lighting.sh"
#include "pbr/pbr.sh"

#include "pbr/attribute_define.sh"

SAMPLER2D(s_height,                3);

#define u_metallic_factor     u_pbr_factor.x
#define u_roughness_factor    u_pbr_factor.y

vec2 texture2DArrayBc5(sampler2DArray _sampler, vec3 _uv)
{
#if BGFX_SHADER_LANGUAGE_HLSL && BGFX_SHADER_LANGUAGE_HLSL <= 300
	return texture2DArray(_sampler, _uv).yx;
#else
	return texture2DArray(_sampler, _uv).xy;
#endif
}


input_attributes init_input_attributes(vec3 gnormal, vec3 normal, vec4 posWS, vec4 basecolor, vec4 fragcoord)
{
    input_attributes input_attribs  = (input_attributes)0;
    input_attribs.basecolor         = basecolor;
    input_attribs.posWS             = posWS.xyz;
    input_attribs.distanceVS        = posWS.w;
    input_attribs.V                 = normalize(u_eyepos.xyz - posWS.xyz);
    input_attribs.gN                = gnormal;  //geomtery normal
    input_attribs.N                 = normal;

    //use stone setting
    input_attribs.perceptual_roughness  = clamp(u_roughness_factor, 0.0, 1.0);
    input_attribs.metallic              = clamp(u_metallic_factor, 0.0, 1.0);
    input_attribs.occlusion         = 1.0;

    input_attribs.screen_uv         = get_normalize_fragcoord(fragcoord.xy);
    return input_attribs;
}

vec2 parallax_mapping(vec2 uv, vec3 view_dir, float num_layers)
{
    float layer_height = 1.0 / num_layers;
    float current_layer_height = 0.0;
    vec2 P = view_dir.xy * 0.1;
    vec2 delta_uv = P / num_layers;
    vec2 current_uv = uv;
    float current_height = texture2D(s_height, current_uv).r;
    for(int i = 0; i < num_layers; ++i){
        current_uv -= delta_uv;
        current_height = texture2D(s_height, current_uv).r;
        current_layer_height += layer_height;
        if(current_layer_height >= current_height){
            break;
        }
    }

    return current_uv;
/*     vec2 prev_uv = current_uv + delta_uv;
    float after_height = current_height - current_layer_height;
    float before_height = texture2D(s_height, current_uv).r - current_layer_height + layer_height;
    float weight = after_height / (after_height - before_height);
    vec2 final_uv = prev_uv * weight + current_uv * (1.0 - weight);
    return final_uv; 
 */
/*     float height = texture2D(s_height, uv).r;
    vec2 p = view_dir.xy / view_dir.z * (height * 0.1);
    return uv - p; */
}

void main()
{   
    v_normal = normalize(v_normal);
    v_tangent = normalize(v_tangent);
    vec3 bitangent = cross(v_normal, v_tangent);
    mat3 tbn = mat3(v_tangent, bitangent, v_normal);
    vec3 tangent_view = mul(u_eyepos.xyz, tbn);
    vec3 tangent_pos  = mul(v_posWS.xyz, tbn);
    vec3 view_dir = normalize(tangent_view - tangent_pos);
    float min_layers = 8.0;
    float max_layers = 32.0;
    float num_layers = mix(max_layers, min_layers, max(dot(vec3(0, 0, 1), view_dir), 0));
    vec2 uv = parallax_mapping(v_texcoord0, view_dir, num_layers);
    if(uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0){
        discard;
    } 
    vec4 basecolor = texture2D(s_basecolor, uv);
    vec3 normal = normal_from_tangent_frame(tbn, uv);
    input_attributes input_attribs = init_input_attributes(v_normal, normal, v_posWS, basecolor, gl_FragCoord);

    gl_FragColor = compute_lighting(input_attribs);

}



