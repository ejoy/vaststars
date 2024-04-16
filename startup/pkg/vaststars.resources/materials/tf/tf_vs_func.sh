#include "common/transform.sh"
#include "common/common.sh"
#include "default/utils.sh"

void CUSTOM_VS(mat4 worldmat, VSInput vsinput, inout Varyings varyings)
{
	varyings.texcoord0	= vsinput.texcoord0;
}