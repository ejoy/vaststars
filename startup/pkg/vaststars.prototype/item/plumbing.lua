local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "液罐I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 40,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/storage-tank.texture",
    backpack_limit = 20,
    item_description = "用于储存流体的容器",
}

prototype "液罐II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 42,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/storage-tank.texture",
    backpack_limit = 20,
    item_description = "用于储存流体的容器",
}

prototype "液罐III" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 43,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/storage-tank.texture",
    backpack_limit = 20,
    item_description = "用于储存流体的容器",
}

prototype "气罐I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 50,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/hydroplant.texture",
    backpack_limit = 20,
    item_description = "专门贮藏气体的容器",
}

prototype "地下水挖掘机I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 52,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/water-excavator.texture",
    backpack_limit = 20,
    item_description = "用于从含水层等地下水源中挖掘和提取水的机器",
}

prototype "地下水挖掘机II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 54,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/water-excavator.texture",
    backpack_limit = 20,
    item_description = "用于从含水层等地下水源中挖掘和提取水的机器",
}

prototype "压力泵I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 56,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/motor.texture",
    backpack_limit = 20,
    item_description = "用于增加流体压力的机械设备",
}

prototype "烟囱I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 58,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chimney.texture",
    backpack_limit = 20,
    item_description = "用于排放工业设施中烟气或废气的设施",
}

prototype "烟囱II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 60,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chimney.texture",
    backpack_limit = 20,
    item_description = "用于排放工业设施中烟气或废气的设施",
}

prototype "排水口I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 62,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/outfall.texture",
    backpack_limit = 20,
    item_description = "用于排放多余水分或废水的装置",
}

prototype "排水口II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 64,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/outfall.texture",
    backpack_limit = 20,
    item_description = "用于排放多余水分或废水的装置",
}

prototype "空气过滤器I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 66,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/air-filter.texture",
    backpack_limit = 20,
    item_description = "抽取空气的装置",
}

prototype "空气过滤器II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 68,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/air-filter.texture",
    backpack_limit = 20,
    item_description = "抽取空气的装置",
}

prototype "空气过滤器III" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    hub_limit = 15,
    item_order = 70,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/air-filter.texture",
    backpack_limit = 20,
    item_description = "抽取空气的装置",
}

prototype "管道1-X型" {
    type = {"item"},
    item_category = "化工",
    station_limit = 15,
    hub_limit = 60,
    item_order = 2,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/pipe.texture",
    backpack_limit = 100,
    item_description = "放置在地上传输流体的管道",
}

prototype "地下管1-JI型" {
    type = {"item"},
    item_category = "化工",
    station_limit = 15,
    hub_limit = 60,
    item_order = 4,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/underground-pipe.texture",
    backpack_limit = 100,
    item_description = "放置在地下传输流体的管道",
}

prototype "地下管2-JI型" {
    type = {"item"},
    item_category = "化工",
    station_limit = 15,
    hub_limit = 60,
    item_order = 6,
    item_model = "glbs/stackeditems/gravel.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/underground-pipe.texture",
    backpack_limit = 100,
    item_description = "放置在地下传输流体的管道",
}