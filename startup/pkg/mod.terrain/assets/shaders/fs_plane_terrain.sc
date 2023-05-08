$input v_texcoord v_normal v_tangent v_posWS v_idx

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

#define v_distanceVS v_posWS.w
#ifdef ENABLE_SHADOW
#include "common/shadow.sh"
#endif //ENABLE_SHADOW

#include "pbr/attribute_define.sh"

SAMPLER2DARRAY(s_basecolor,             0);
SAMPLER2DARRAY(s_height,                1);
SAMPLER2DARRAY(s_normal,                2);

uniform vec4 u_metallic_roughness_factor1;
uniform vec4 u_metallic_roughness_factor2;

#define u_stone_metallic_factor     u_metallic_roughness_factor1.z
#define u_stone_roughness_factor    u_metallic_roughness_factor1.w

#define v_sand_color_idx      v_idx.x
#define v_stone_color_idx     v_idx.y
#define v_terrain_coord       v_texcoord.xy
#define v_alpha_coord         v_texcoord.zw
vec2 texture2DArrayBc5(sampler2DArray _sampler, vec3 _uv)
{
#if BGFX_SHADER_LANGUAGE_HLSL && BGFX_SHADER_LANGUAGE_HLSL <= 300
	return texture2DArray(_sampler, _uv).yx;
#else
	return texture2DArray(_sampler, _uv).xy;
#endif
}

mediump vec3 terrain_normal_from_tangent_frame(mat3 tbn, mediump vec2 texcoord, mediump float normal_idx)
{
	mediump vec3 normalTS = remap_normal(texture2DArrayBc5(s_normal, mediump vec3(texcoord, normal_idx)));
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
    input_attribs.perceptual_roughness  = clamp(u_stone_roughness_factor, 0.0, 1.0);
    input_attribs.metallic              = clamp(u_stone_metallic_factor, 0.0, 1.0);
    input_attribs.occlusion         = 1.0;

    input_attribs.screen_uv         = get_normalize_fragcoord(fragcoord.xy);
    return input_attribs;
}

vec3 blend_terrain_color(vec3 sand_basecolor, vec3 stone_basecolor, float sand_height, float sand_alpha)
{
    float sand_weight = min(1.0, 2.5 * abs(sand_height - sand_alpha));
    float stone_weight = 1 - sand_weight;
    return stone_basecolor*stone_weight + sand_basecolor*sand_weight;
}

void main()
{ 
    //v_texcoord0 terrain_basecolor/terrain_height/terrain_normal 8x8
    //v_texcoord1 sand_alpha 32x32
    const vec2 terrain_uv = v_terrain_coord;
    const vec2 sand_alpha_uv  = v_alpha_coord;
    vec4 stone_basecolor   = texture2DArray(s_basecolor, vec3(terrain_uv, v_stone_color_idx));
    vec4 sand_basecolor    = texture2DArray(s_basecolor, vec3(terrain_uv, v_sand_color_idx));

    float sand_height   = texture2DArray(s_height, vec3(terrain_uv, 0.0) );
    float stone_height  = texture2DArray(s_height, vec3(terrain_uv, 1.0) );
    float sand_alpha = texture2DArray(s_height, vec3(sand_alpha_uv, 2.0) );
    vec3 terrain_color = blend_terrain_color(sand_basecolor.rgb, stone_basecolor.rgb, sand_height, sand_alpha);

    vec3 basecolor = terrain_color;

    v_normal = normalize(v_normal);
    v_tangent = normalize(v_tangent);
    vec3 bitangent = cross(v_normal, v_tangent);
    mat3 tbn = mat3(v_tangent, bitangent, v_normal);
    vec3 stone_normal = terrain_normal_from_tangent_frame(tbn, terrain_uv, 1);
    input_attributes input_attribs = init_input_attributes(v_normal, stone_normal, v_posWS, vec4(basecolor, 1.0), gl_FragCoord);
    gl_FragColor = compute_lighting(input_attribs); 
    //gl_FragColor = vec4(basecolor, 1.0);
}



