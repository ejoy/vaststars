--物品在仓库显示大小为:4X4、4X2、4X1、2X1四种

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "山丘" {
    icon = "textures/construct/alumina.texture",
    item_description = "地面上的沙丘",
}