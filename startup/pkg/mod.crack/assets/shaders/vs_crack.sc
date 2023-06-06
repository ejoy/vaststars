#include "common/inputs.sh"
$input 	a_position a_texcoord0 INPUT_NORMAL INPUT_TANGENT
$output v_texcoord0 v_normal v_tangent v_posWS
#include <bgfx_shader.sh>
#include "common/transform.sh"

void main()
{
	mat4 wm = get_world_matrix();
	highp vec4 posWS = transformWS(wm, mediump vec4(a_position, 1.0));
	gl_Position = mul(u_viewProj, posWS);
	v_texcoord0 = a_texcoord0;
	
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