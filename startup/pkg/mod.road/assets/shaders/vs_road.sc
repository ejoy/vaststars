#include "common/inputs.sh"

$input 	a_position a_texcoord0 a_texcoord1 a_texcoord2 a_texcoord3
$output v_texcoord v_normal v_tangent v_posWS v_idx

#include <bgfx_shader.sh>
#include "common/transform.sh"

void main()
{
	
	//p3
	//t20 1x1 road color/height/normal
	//t21 1x1 mark color/alpha
	//t22 flat road type/shape
	//t23 flat mark type/shape
    mat4 wm = u_model[0];
	highp vec4 posWS = transformWS(wm, mediump vec4(a_position, 1.0));
	gl_Position = mul(u_viewProj, posWS);
	v_texcoord	= vec4(a_texcoord0, a_texcoord1);
	v_idx		= vec4(a_texcoord2, a_texcoord3);
	v_normal	= mul(wm, mediump vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	v_tangent	= mul(wm, mediump vec4(1.0, 0.0, 0.0, 0.0)).xyz;

	v_posWS = posWS;
	v_posWS.w = mul(u_view, v_posWS).z;
}