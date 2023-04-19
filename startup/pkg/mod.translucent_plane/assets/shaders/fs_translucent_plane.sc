#include <bgfx_shader.sh>
uniform vec4 u_colorTable;
void main()
{
	gl_FragColor = u_colorTable;
}


