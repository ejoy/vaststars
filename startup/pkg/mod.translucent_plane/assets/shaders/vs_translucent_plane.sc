$input a_position a_texcoord0
$output v_corner_uv
#include <bgfx_shader.sh>
#include "common/transform.sh"
void main()
{
	mat4 wm = u_model[0];
	highp vec4 posWS = transformWS(wm, mediump vec4(a_position, 1.0));
	v_corner_uv = a_texcoord0.xy;
	gl_Position   = mul(u_viewProj, posWS);	
}