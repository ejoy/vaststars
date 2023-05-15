$input v_corner_uv
#include <bgfx_shader.sh>
uniform vec4 u_colorTable;
SAMPLER2D(s_corner,             0);
void main()
{
	float corner_alpha = texture2D(s_corner, v_corner_uv);
	if(corner_alpha == 1){
		gl_FragColor = vec4(u_colorTable.xyz, 0);
	}
	else{
		gl_FragColor = u_colorTable;
	}
}


