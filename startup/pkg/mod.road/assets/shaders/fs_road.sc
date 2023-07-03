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

#define v_distanceVS v_posWS.w
#ifdef ENABLE_SHADOW
#include "common/shadow.sh"
#endif //ENABLE_SHADOW

#include "pbr/attribute_define.sh"

SAMPLER2D(s_basecolor,             0);
SAMPLER2D(s_metallic_roughness,    1);
SAMPLER2DARRAY(s_mark_alpha,       3);

#define v_road_type        v_idx.x
#define v_road_shape       v_idx.y
#define v_mark_type        v_idx.z
#define v_mark_shape       v_idx.w
#define v_road_coord       v_texcoord.xy
#define v_mark_coord       v_texcoord.zw

vec3 blend(vec3 texture1, float a1, float d1, vec3 texture2, float a2, float d2){
    float depth = 0.2;
    float ma = max(d1 + a1, d2 + a2) - depth;

    float b1 = max(d1  + a1 - ma, 0);
    float b2 = max(d2  + a2 - ma, 0);

    return (texture1.rgb * b1 + texture2.rgb * b2) / (b1 + b2);
}

input_attributes init_input_attributes(vec3 gnormal, vec3 normal, vec4 posWS, vec4 basecolor, vec4 fragcoord, vec4 metallic, vec4 roughness)
{
    input_attributes input_attribs  = (input_attributes)0;
    input_attribs.basecolor         = basecolor;
    input_attribs.posWS             = posWS.xyz;
    input_attribs.distanceVS        = posWS.w;
    input_attribs.V                 = normalize(u_eyepos.xyz - posWS.xyz);
    input_attribs.gN                = gnormal;  //geomtery normal
    input_attribs.N                 = normal;

    input_attribs.perceptual_roughness  = roughness;
    input_attribs.metallic              = metallic;
    input_attribs.occlusion         = 1.0;

    input_attribs.screen_uv         = get_normalize_fragcoord(fragcoord.xy);
    return input_attribs;
}

vec3 calc_road_basecolor(vec4 road_basecolor, float road_type)
{
    vec3 stop_color   = vec3(255.0/255,  37.0/255,  37.0/255);
    vec3 choose_color = vec3(228.0/255, 228.0/255, 228.0/255);
    if(road_type == 1){
        return road_basecolor.rgb;
    }
    else if (road_type == 2){
        return vec3((stop_color.r+road_basecolor.r)*0.5, (stop_color.g+road_basecolor.g)*0.5, (stop_color.b+road_basecolor.b)*0.5);
    }
    else{
        return vec3((choose_color.r+road_basecolor.r)*0.5, (choose_color.g+road_basecolor.g)*0.5, (choose_color.b+road_basecolor.b)*0.5);
    }  
}

vec3 calc_road_mark_blend_color(float road_type, vec4 road_basecolor, float mark_type, vec4 mark_basecolor, float mark_alpha)
{

    if(road_type != 0.0 && mark_type != 0.0)
    {
        vec3 tmp_color = calc_road_basecolor(road_basecolor, road_type);
        return blend(mark_basecolor.rgb, 1.0 - mark_alpha, 0.5, tmp_color, mark_alpha, 0.5); 
    }
    else if(road_type != 0.0 && mark_type == 0.0)
    {
        return calc_road_basecolor(road_basecolor, road_type);
    }
    else if(road_type == 0.0 && mark_type != 0.0)
    {
        return mark_basecolor.rgb;
    }
    else
    {
        return road_basecolor.rgb;
    }
}

void main()
{ 
	//t0 1x1 road color/height/normal
	//t1 1x1 mark color/alpha
    const vec2 road_uv  = v_road_coord;
    const vec2 mark_uv  = v_mark_coord;

    vec4 road_basecolor = texture2D(s_basecolor, vec3(road_uv, v_road_shape));

    vec4 mark_basecolor = vec4(0, 0, 0, 0);
    float mark_alpha = 0;
    
    if(v_mark_type != 0){
        mark_alpha = texture2DArray(s_mark_alpha, vec3(mark_uv, v_mark_shape));
        if(v_mark_type == 1){
            mark_basecolor = vec4(0.71484, 0, 0, 1);
        }
        else{
            mark_basecolor = vec4(1, 1, 1, 1);
        }
    }   

    vec3 basecolor = calc_road_mark_blend_color(v_road_type, road_basecolor, v_mark_type, mark_basecolor, mark_alpha);

    bool is_road_part = v_road_type != 0;
    bool is_mark_part = v_mark_type != 0;
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
/*         v_normal = normalize(v_normal);
        v_tangent = normalize(v_tangent);
        vec3 bitangent = cross(v_normal, v_tangent);
        mat3 tbn = mat3(v_tangent, bitangent, v_normal);
        vec3 road_normal = terrain_normal_from_tangent_frame(tbn, road_uv, v_road_shape); */
        input_attributes input_attribs = init_input_attributes(v_normal, v_normal, v_posWS, vec4(basecolor, 1.0), gl_FragCoord, metallic, roughness);
        gl_FragColor = compute_lighting(input_attribs);
    }
}



