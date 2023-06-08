#include "common/inputs.sh"

$input 	a_position a_texcoord0 a_texcoord1 i_data0 i_data1 i_data2
$output v_texcoord v_normal v_tangent v_posWS v_idx

#include <bgfx_shader.sh>
#include "common/transform.sh"

#define road_type  i_data2.x
#define road_shape i_data2.y
#define mark_type  i_data2.z
#define mark_shape i_data2.w

#define road_texcoord_r i_data1.x
#define mark_texcoord_r i_data1.y

vec2 get_tex(float idx){
	if(idx == 0){
		return vec2(0, 1);
	}
	else if(idx == 1){
		return vec2(0, 0);
	}
	else if(idx == 2){
		return vec2(1, 0);
	}
	else return vec2(1, 1);
}

vec2 get_rotated_texcoord(float r, vec2 tex){
	if(tex.x == 0 && tex.y == 1){
		return get_tex((r / 90) % 4);
	}
	else if(tex.x == 0 && tex.y == 0){
		return get_tex((r / 90 + 1) % 4);
	}
	else if(tex.x == 1 && tex.y == 0){
		return get_tex((r / 90 + 2) % 4);
	}
	else{
		return get_tex((r / 90 + 3) % 4);
	}
}

void main()
{
#ifdef DRAW_INDIRECT
	mediump mat4 wm = get_indirect_wolrd_matrix(i_data0, i_data1, i_data2, u_draw_indirect_type);
#else
	mediump mat4 wm = get_world_matrix();
#endif //DRAW_INDIRECT
	highp vec4 posWS = transformWS(wm, mediump vec4(a_position, 1.0));
	gl_Position = mul(u_viewProj, posWS);
	v_texcoord	= vec4(get_rotated_texcoord(road_texcoord_r, a_texcoord0).xy, get_rotated_texcoord(mark_texcoord_r, a_texcoord1).xy);
	v_idx		= vec4(road_type, road_shape, mark_type, mark_shape);
	v_normal	= mul(wm, mediump vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	v_tangent	= mul(wm, mediump vec4(1.0, 0.0, 0.0, 0.0)).xyz;

	v_posWS = posWS;
	v_posWS.w = mul(u_view, v_posWS).z;
}