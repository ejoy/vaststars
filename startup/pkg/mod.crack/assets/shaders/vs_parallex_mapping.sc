#include "common/default_inputs_define.sh"
$input 	a_position a_texcoord0 INPUT_NORMAL INPUT_TANGENT
$output v_texcoord0 v_normal v_tangent v_posWS
#include <bgfx_shader.sh>
#include "common/transform.sh"
#include "common/default_inputs_structure.sh"

void main()
{
	VSInput vs_input = (VSInput)0;
	#include "common/default_vs_inputs_getter.sh"
	mat4 wm = get_world_matrix(vs_input);
	highp vec4 posWS = transform_pos(wm, a_position, gl_Position);

	v_texcoord0 = a_texcoord0;
	//TODO: need to use vs_default.sc
#	if PACK_TANGENT_TO_QUAT
	const mediump vec4 quat = a_tangent;
	mediump vec3 normal = quat_to_normal(quat);
	mediump vec3 tangent = quat_to_tangent(quat);
#	else //!PACK_TANGENT_TO_QUAT
	mediump vec3 normal = a_normal;
	mediump vec3 tangent = a_tangent.xyz;
#	endif//PACK_TANGENT_TO_QUAT

	v_normal	= mul(wm, mediump vec4(normal, 0.0)).xyz;
	v_tangent	= mul(wm, mediump vec4(tangent, 0.0)).xyz * sign(a_tangent.w);
	v_posWS = posWS;
	v_posWS.w = mul(u_view, v_posWS).z;
	
}