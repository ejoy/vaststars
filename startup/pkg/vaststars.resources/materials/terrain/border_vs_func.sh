#include <bgfx_shader.sh>
#include "common/transform.sh"
#include "common/common.sh"
#include "default/utils.sh"

void CUSTOM_VS(mat4 wm, VSInput vsinput, inout Varyings varyings)
{
	varyings.texcoord0	= vsinput.texcoord0;
	mat3 wm3 = (mat3)wm;
	varyings.normal		= mul(wm3, vec3(0.0, 1.0, 0.0));
	varyings.tangent	= mul(wm3, vec3(1.0, 0.0, 0.0));
	varyings.bitangent	= mul(wm3, vec3(0.0, 0.0,-1.0));
}