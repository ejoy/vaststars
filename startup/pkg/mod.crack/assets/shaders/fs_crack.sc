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

SAMPLER2D(s_color,                 0);
SAMPLER2D(s_normal,                1);
SAMPLER2D(s_height,                2);
SAMPLER2D(s_alpha,                 3);

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

mediump vec3 normal_from_tangent_frame(mat3 tbn, mediump vec2 texcoord)
{
	mediump vec3 normalTS = remap_normal(texture2DBc5(s_normal, texcoord));
	// same as: mul(transpose(tbn), normalTS)
    return normalize(mul(normalTS, tbn));
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

vec2 parallax_mapping(vec2 uv, vec3 view_dir)
{
    float num_layers = 10.0;
    float layer_height = 1.0 / num_layers;
    float current_layer_height = 0.0;
    vec2 P = view_dir.xy * 0.1;
    vec2 delta_uv = P / num_layers;
    vec2 current_uv = uv;
    float current_height = 1 - texture2D(s_height, current_uv).r;
    for(int i = 0; i < num_layers; ++i){
        current_uv -= delta_uv;
        current_height = 1 - texture2D(s_height, current_uv).r;
        current_layer_height += layer_height;
        if(current_layer_height >= current_height){
            break;
        }
    }
    return current_uv;
}

void main()
{   
    vec3 pos = mul(u_viewProj, v_posWS).xyz;
    v_normal = normalize(v_normal);
    v_tangent = normalize(v_tangent);
    vec3 bitangent = cross(v_normal, v_tangent);
    mat3 tbn = mat3(v_tangent, bitangent, v_normal);
    vec3 tangent_view = mul(u_eyepos.xyz, tbn);
    vec3 tangent_pos  = mul(pos, tbn);
    vec3 view_dir = normalize(tangent_view - tangent_pos);
    vec2 uv = parallax_mapping(v_texcoord0, view_dir);
    if(uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0){
        discard;
    }
    vec3 basecolor = texture2D(s_color, uv);
    float alpha = 1 - texture2D(s_alpha, uv).x;
    vec3 normal = normal_from_tangent_frame(tbn, uv);
    input_attributes input_attribs = init_input_attributes(v_normal, normal, v_posWS, vec4(basecolor, alpha), gl_FragCoord);
    gl_FragColor = compute_lighting(input_attribs);

}



