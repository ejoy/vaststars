#include "common/transform.sh"
#include "default/utils.sh"

void CUSTOM_VS(mat4 wm, VSInput vsinput, inout Varyings varyings)
{
    varyings.texcoord0 = vsinput.texcoord0;

    // normal
    unpack_tbn_from_quat(wm, vsinput, varyings);
}