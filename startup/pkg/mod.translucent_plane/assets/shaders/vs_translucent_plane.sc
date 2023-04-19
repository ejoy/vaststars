$input a_position
#include <bgfx_shader.sh>
#include "common/transform.sh"
void main()
{
	mat4 wm = u_model[0];
	highp vec4 posWS = transformWS(wm, mediump vec4(a_position, 1.0));
	gl_Position   = mul(u_viewProj, posWS);	
}